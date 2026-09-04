#include "hyprlandbackend.h"
#include <QProcessEnvironment>
#include <QJsonArray>
#include <QJsonObject>
#include <QDebug>

HyprlandBackend::HyprlandBackend(QObject *parent)
    : CompositorBackend(parent)
{
    m_signature = QProcessEnvironment::systemEnvironment()
                      .value("HYPRLAND_INSTANCE_SIGNATURE");

    m_reconnectTimer.setInterval(3000);
    m_reconnectTimer.setSingleShot(true);
    connect(&m_reconnectTimer, &QTimer::timeout,
            this, &HyprlandBackend::reconnectEventSocket);
}

HyprlandBackend::~HyprlandBackend()
{
    m_eventSocket.disconnectFromServer();
}

// ── Socket path helpers ──────────────────────────────────────

QString HyprlandBackend::socketPath(const QString &name) const
{
    QString runtime = QProcessEnvironment::systemEnvironment().value("XDG_RUNTIME_DIR", "/run/user/1000");
    return QString("%1/hypr/%2/%3").arg(runtime, m_signature, name);
}

// ── Command socket (request/response) ───────────────────────

QByteArray HyprlandBackend::sendCommand(const QString &command)
{
    QLocalSocket sock;
    sock.connectToServer(socketPath(".socket.sock"));
    if (!sock.waitForConnected(1000)) {
        qWarning() << "[Hyprland] Command socket connect failed:" << sock.errorString();
        return {};
    }
    sock.write(command.toUtf8());
    sock.flush();
    sock.waitForBytesWritten(1000);
    sock.waitForReadyRead(2000);
    QByteArray result = sock.readAll();
    sock.disconnectFromServer();
    return result;
}

// ── Initialization ───────────────────────────────────────────

void HyprlandBackend::initialize()
{
    connectEventSocket();
    listWorkspaces();
    listWindows();
}

void HyprlandBackend::connectEventSocket()
{
    connect(&m_eventSocket, &QLocalSocket::readyRead,
            this, &HyprlandBackend::onEventSocketData);
    connect(&m_eventSocket, &QLocalSocket::errorOccurred,
            this, &HyprlandBackend::onEventSocketError);

    m_eventSocket.connectToServer(socketPath(".socket2.sock"));
    if (!m_eventSocket.waitForConnected(2000)) {
        qWarning() << "[Hyprland] Event socket not available, retrying in 3s";
        m_reconnectTimer.start();
    }
}

void HyprlandBackend::reconnectEventSocket()
{
    m_eventSocket.disconnectFromServer();
    connectEventSocket();
}

// ── Live queries ─────────────────────────────────────────────

void HyprlandBackend::listWorkspaces()
{
    QByteArray data = sendCommand("j/workspaces");
    if (data.isEmpty()) return;
    emit workspacesUpdated(parseWorkspaces(data));

    // Also query active workspace
    QByteArray active = sendCommand("j/activeworkspace");
    if (!active.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(active);
        int id = doc.object().value("id").toInt();
        emit activeWorkspaceChanged(id);
    }
}

void HyprlandBackend::listWindows()
{
    QByteArray data = sendCommand("j/clients");
    if (data.isEmpty()) return;
    emit windowsUpdated(parseWindows(data));

    // Query focused window
    QByteArray active = sendCommand("j/activewindow");
    if (!active.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(active);
        QString addr = doc.object().value("address").toString();
        if (!addr.isEmpty()) emit focusedWindowChanged(addr);
    }
}

// ── Actions ──────────────────────────────────────────────────

void HyprlandBackend::switchWorkspace(int id)
{
    sendCommand(QString("dispatch workspace %1").arg(id));
}

void HyprlandBackend::focusWindow(const QString &address)
{
    sendCommand(QString("dispatch focuswindow address:%1").arg(address));
}

void HyprlandBackend::closeWindow(const QString &address)
{
    sendCommand(QString("dispatch closewindow address:%1").arg(address));
}

void HyprlandBackend::moveWindowToWorkspace(const QString &address, int workspaceId)
{
    sendCommand(QString("dispatch movetoworkspacesilent %1,address:%2")
                .arg(workspaceId).arg(address));
}

// ── Event socket handling ────────────────────────────────────

void HyprlandBackend::onEventSocketData()
{
    m_eventBuffer += m_eventSocket.readAll();
    while (m_eventBuffer.contains('\n')) {
        int idx = m_eventBuffer.indexOf('\n');
        QString line = QString::fromUtf8(m_eventBuffer.left(idx)).trimmed();
        m_eventBuffer.remove(0, idx + 1);
        if (!line.isEmpty()) processEvent(line);
    }
}

void HyprlandBackend::onEventSocketError(QLocalSocket::LocalSocketError error)
{
    Q_UNUSED(error)
    qWarning() << "[Hyprland] Event socket error:" << m_eventSocket.errorString();
    m_reconnectTimer.start();
}

void HyprlandBackend::processEvent(const QString &event)
{
    // Hyprland events are: "eventname>>data"
    int sep = event.indexOf(">>");
    if (sep < 0) return;
    QString name = event.left(sep);
    QString data = event.mid(sep + 2);

    if (name == "workspace") {
        // workspace activated: data = workspace name/id
        bool ok;
        int id = data.toInt(&ok);
        if (ok) emit activeWorkspaceChanged(id);
        listWorkspaces();
    } else if (name == "activewindow" || name == "activewindowv2") {
        listWindows();
    } else if (name == "openwindow" || name == "closewindow" || name == "movewindow") {
        listWindows();
    } else if (name == "createworkspace" || name == "destroyworkspace") {
        listWorkspaces();
    } else if (name == "focusedmon") {
        // data = "monitorname,workspaceid"
        listWorkspaces();
        listWindows();
    }
}

// ── JSON parsers ─────────────────────────────────────────────

QList<WorkspaceInfo*> HyprlandBackend::parseWorkspaces(const QByteArray &json)
{
    QList<WorkspaceInfo*> result;
    QJsonDocument doc = QJsonDocument::fromJson(json);
    if (!doc.isArray()) return result;

    for (const QJsonValue &val : doc.array()) {
        QJsonObject obj = val.toObject();
        int     id   = obj.value("id").toInt();
        QString name = obj.value("name").toString();
        auto   *ws   = new WorkspaceInfo(id, name);
        ws->setWindows(obj.value("windows").toInt());
        result.append(ws);
    }
    return result;
}

QList<WindowInfo*> HyprlandBackend::parseWindows(const QByteArray &json)
{
    QList<WindowInfo*> result;
    QJsonDocument doc = QJsonDocument::fromJson(json);
    if (!doc.isArray()) return result;

    for (const QJsonValue &val : doc.array()) {
        QJsonObject obj     = val.toObject();
        QString     address = obj.value("address").toString();
        auto       *win     = new WindowInfo(address);
        win->setTitle(obj.value("title").toString());
        win->setAppClass(obj.value("class").toString());
        win->setWorkspaceId(obj.value("workspace").toObject().value("id").toInt());
        win->setFloating(obj.value("floating").toBool());
        result.append(win);
    }
    return result;
}
