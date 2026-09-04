#include "compositorservice.h"
#include "hyprlandbackend.h"
#include <QProcessEnvironment>
#include <QDebug>

// ─────────────────────────────────────────────────────────────
// WorkspaceInfo
// ─────────────────────────────────────────────────────────────
WorkspaceInfo::WorkspaceInfo(int id, const QString &name, QObject *parent)
    : QObject(parent), m_id(id), m_name(name)
{}

void WorkspaceInfo::setName(const QString &v)    { if (m_name    != v) { m_name    = v; emit nameChanged();    } }
void WorkspaceInfo::setActive(bool v)            { if (m_active  != v) { m_active  = v; emit activeChanged();  } }
void WorkspaceInfo::setWindows(int v)            { if (m_windows != v) { m_windows = v; emit windowsChanged(); } }

// ─────────────────────────────────────────────────────────────
// WindowInfo
// ─────────────────────────────────────────────────────────────
WindowInfo::WindowInfo(const QString &address, QObject *parent)
    : QObject(parent), m_address(address)
{}

void WindowInfo::setTitle(const QString &v)      { if (m_title       != v) { m_title       = v; emit titleChanged();       } }
void WindowInfo::setAppClass(const QString &v)   { if (m_appClass    != v) { m_appClass    = v; emit appClassChanged();    } }
void WindowInfo::setWorkspaceId(int v)           { if (m_workspaceId != v) { m_workspaceId = v; emit workspaceIdChanged(); } }
void WindowInfo::setFocused(bool v)              { if (m_focused     != v) { m_focused     = v; emit focusedChanged();     } }
void WindowInfo::setFloating(bool v)             { if (m_floating    != v) { m_floating    = v; emit floatingChanged();    } }

// ─────────────────────────────────────────────────────────────
// CompositorService
// ─────────────────────────────────────────────────────────────
CompositorService* CompositorService::create(QObject *parent)
{
    auto *svc = new CompositorService(parent);

    // Detect compositor from environment
    QString sig = QProcessEnvironment::systemEnvironment().value("HYPRLAND_INSTANCE_SIGNATURE");
    if (!sig.isEmpty()) {
        svc->m_backend = new HyprlandBackend(svc);
    } else {
        // TODO: detect Sway/Niri and instantiate appropriate backend
        qWarning() << "[CompositorService] No known compositor detected. "
                   << "Running without compositor integration.";
    }

    if (svc->m_backend) {
        connect(svc->m_backend, &CompositorBackend::workspacesUpdated,
                svc, &CompositorService::onWorkspacesUpdated);
        connect(svc->m_backend, &CompositorBackend::windowsUpdated,
                svc, &CompositorService::onWindowsUpdated);
        connect(svc->m_backend, &CompositorBackend::activeWorkspaceChanged,
                svc, &CompositorService::onActiveWorkspaceChanged);
        connect(svc->m_backend, &CompositorBackend::focusedWindowChanged,
                svc, &CompositorService::onFocusedWindowChanged);
        svc->m_backend->initialize();
    }

    return svc;
}

CompositorService::CompositorService(QObject *parent)
    : QObject(parent)
{}

CompositorService::~CompositorService() = default;

QList<QObject*> CompositorService::workspaces() const
{
    QList<QObject*> out;
    for (auto *w : m_workspaces) out.append(w);
    return out;
}

QList<QObject*> CompositorService::windows() const
{
    QList<QObject*> out;
    for (auto *w : m_windows) out.append(w);
    return out;
}

QString CompositorService::activeAppClass() const
{
    for (auto *w : m_windows) {
        if (w->address() == m_focusedWindow) return w->appClass();
    }
    return {};
}

QString CompositorService::activeAppTitle() const
{
    for (auto *w : m_windows) {
        if (w->address() == m_focusedWindow) return w->title();
    }
    return {};
}

void CompositorService::switchWorkspace(int id)
{
    if (m_backend) m_backend->switchWorkspace(id);
}

void CompositorService::focusWindow(const QString &address)
{
    if (m_backend) m_backend->focusWindow(address);
}

void CompositorService::closeWindow(const QString &address)
{
    if (m_backend) m_backend->closeWindow(address);
}

void CompositorService::moveWindowToWorkspace(const QString &address, int workspaceId)
{
    if (m_backend) m_backend->moveWindowToWorkspace(address, workspaceId);
}

void CompositorService::refresh()
{
    if (m_backend) {
        m_backend->listWorkspaces();
        m_backend->listWindows();
    }
}

void CompositorService::onWorkspacesUpdated(const QList<WorkspaceInfo*> &ws)
{
    // Clear old owned items before replacing
    qDeleteAll(m_workspaces);
    m_workspaces.clear();
    m_workspaces = ws;
    for (auto *w : m_workspaces) w->setParent(this);
    emit workspacesChanged();
}

void CompositorService::onWindowsUpdated(const QList<WindowInfo*> &wins)
{
    qDeleteAll(m_windows);
    m_windows.clear();
    m_windows = wins;
    for (auto *w : m_windows) w->setParent(this);
    emit windowsChanged();
}

void CompositorService::onActiveWorkspaceChanged(int id)
{
    if (m_activeWorkspace == id) return;
    m_activeWorkspace = id;
    for (auto *ws : m_workspaces) ws->setActive(ws->id() == id);
    emit activeWorkspaceChanged();
}

void CompositorService::onFocusedWindowChanged(const QString &address)
{
    if (m_focusedWindow == address) return;
    m_focusedWindow = address;
    for (auto *w : m_windows) w->setFocused(w->address() == address);
    emit focusedWindowChanged();
}
