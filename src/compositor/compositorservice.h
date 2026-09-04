#pragma once

#include <QObject>
#include <QList>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// WorkspaceInfo — value object representing one workspace
// ─────────────────────────────────────────────────────────────
class WorkspaceInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int     id      READ id      CONSTANT)
    Q_PROPERTY(QString name    READ name    NOTIFY nameChanged)
    Q_PROPERTY(bool    active  READ active  NOTIFY activeChanged)
    Q_PROPERTY(int     windows READ windows NOTIFY windowsChanged)

public:
    explicit WorkspaceInfo(int id, const QString &name, QObject *parent = nullptr);

    int     id()      const { return m_id; }
    QString name()    const { return m_name; }
    bool    active()  const { return m_active; }
    int     windows() const { return m_windows; }

    void setName(const QString &v);
    void setActive(bool v);
    void setWindows(int v);

signals:
    void nameChanged();
    void activeChanged();
    void windowsChanged();

private:
    int     m_id;
    QString m_name;
    bool    m_active  = false;
    int     m_windows = 0;
};

// ─────────────────────────────────────────────────────────────
// WindowInfo — value object representing a client window
// ─────────────────────────────────────────────────────────────
class WindowInfo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString address     READ address     CONSTANT)
    Q_PROPERTY(QString title       READ title       NOTIFY titleChanged)
    Q_PROPERTY(QString appClass    READ appClass    NOTIFY appClassChanged)
    Q_PROPERTY(int     workspaceId READ workspaceId NOTIFY workspaceIdChanged)
    Q_PROPERTY(bool    focused     READ focused     NOTIFY focusedChanged)
    Q_PROPERTY(bool    floating    READ floating    NOTIFY floatingChanged)

public:
    explicit WindowInfo(const QString &address, QObject *parent = nullptr);

    QString address()     const { return m_address; }
    QString title()       const { return m_title; }
    QString appClass()    const { return m_appClass; }
    int     workspaceId() const { return m_workspaceId; }
    bool    focused()     const { return m_focused; }
    bool    floating()    const { return m_floating; }

    void setTitle(const QString &v);
    void setAppClass(const QString &v);
    void setWorkspaceId(int v);
    void setFocused(bool v);
    void setFloating(bool v);

signals:
    void titleChanged();
    void appClassChanged();
    void workspaceIdChanged();
    void focusedChanged();
    void floatingChanged();

private:
    QString m_address;
    QString m_title;
    QString m_appClass;
    int     m_workspaceId = 0;
    bool    m_focused     = false;
    bool    m_floating    = false;
};

// ─────────────────────────────────────────────────────────────
// CompositorBackend — abstract interface for compositor IPC
// ─────────────────────────────────────────────────────────────
class CompositorBackend : public QObject
{
    Q_OBJECT
public:
    explicit CompositorBackend(QObject *parent = nullptr) : QObject(parent) {}
    virtual ~CompositorBackend() = default;

    virtual void initialize() = 0;
    virtual void listWorkspaces() = 0;
    virtual void listWindows() = 0;
    virtual void switchWorkspace(int id) = 0;
    virtual void focusWindow(const QString &address) = 0;
    virtual void closeWindow(const QString &address) = 0;
    virtual void moveWindowToWorkspace(const QString &address, int workspaceId) = 0;

signals:
    void workspacesUpdated(const QList<WorkspaceInfo*> &workspaces);
    void windowsUpdated(const QList<WindowInfo*> &windows);
    void activeWorkspaceChanged(int id);
    void focusedWindowChanged(const QString &address);
};

// ─────────────────────────────────────────────────────────────
// CompositorService — facade exposed to QML
// ─────────────────────────────────────────────────────────────
class CompositorService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QList<QObject*> workspaces      READ workspaces      NOTIFY workspacesChanged)
    Q_PROPERTY(QList<QObject*> windows         READ windows         NOTIFY windowsChanged)
    Q_PROPERTY(int             activeWorkspace  READ activeWorkspace NOTIFY activeWorkspaceChanged)
    Q_PROPERTY(QString         focusedWindow   READ focusedWindow   NOTIFY focusedWindowChanged)
    Q_PROPERTY(QString         activeAppClass  READ activeAppClass  NOTIFY focusedWindowChanged)
    Q_PROPERTY(QString         activeAppTitle  READ activeAppTitle  NOTIFY focusedWindowChanged)

public:
    explicit CompositorService(QObject *parent = nullptr);
    ~CompositorService() override;

    // Factory: detects compositor and creates appropriate backend
    static CompositorService* create(QObject *parent = nullptr);

    QList<QObject*> workspaces() const;
    QList<QObject*> windows()    const;
    int             activeWorkspace()  const { return m_activeWorkspace; }
    QString         focusedWindow()    const { return m_focusedWindow; }
    QString         activeAppClass()   const;
    QString         activeAppTitle()   const;

public slots:
    Q_INVOKABLE void switchWorkspace(int id);
    Q_INVOKABLE void focusWindow(const QString &address);
    Q_INVOKABLE void closeWindow(const QString &address);
    Q_INVOKABLE void moveWindowToWorkspace(const QString &address, int workspaceId);
    Q_INVOKABLE void refresh();

signals:
    void workspacesChanged();
    void windowsChanged();
    void activeWorkspaceChanged();
    void focusedWindowChanged();

private slots:
    void onWorkspacesUpdated(const QList<WorkspaceInfo*> &ws);
    void onWindowsUpdated(const QList<WindowInfo*> &wins);
    void onActiveWorkspaceChanged(int id);
    void onFocusedWindowChanged(const QString &address);

private:
    CompositorBackend   *m_backend = nullptr;
    QList<WorkspaceInfo*> m_workspaces;
    QList<WindowInfo*>    m_windows;
    int                   m_activeWorkspace = 0;
    QString               m_focusedWindow;
};
