#pragma once

#include "compositorservice.h"
#include <QLocalSocket>
#include <QTimer>
#include <QJsonDocument>

// ─────────────────────────────────────────────────────────────
// HyprlandBackend — IPC communication with Hyprland compositor
//
// Communicates via Hyprland's Unix socket:
//   $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock
//   $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock (events)
// ─────────────────────────────────────────────────────────────
class HyprlandBackend : public CompositorBackend
{
    Q_OBJECT
public:
    explicit HyprlandBackend(QObject *parent = nullptr);
    ~HyprlandBackend() override;

    void initialize()                                                        override;
    void listWorkspaces()                                                    override;
    void listWindows()                                                       override;
    void switchWorkspace(int id)                                             override;
    void focusWindow(const QString &address)                                 override;
    void closeWindow(const QString &address)                                 override;
    void moveWindowToWorkspace(const QString &address, int workspaceId)      override;

private slots:
    void onEventSocketData();
    void onEventSocketError(QLocalSocket::LocalSocketError error);
    void reconnectEventSocket();

private:
    QByteArray sendCommand(const QString &command);
    QString    socketPath(const QString &name) const;
    void       connectEventSocket();
    void       processEvent(const QString &event);
    QList<WorkspaceInfo*> parseWorkspaces(const QByteArray &json);
    QList<WindowInfo*>    parseWindows(const QByteArray &json);

    QString      m_signature;
    QLocalSocket m_eventSocket;
    QByteArray   m_eventBuffer;
    QTimer       m_reconnectTimer;
};
