#pragma once

#include <QObject>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// PowerService — systemd-logind D-Bus power/session actions
// ─────────────────────────────────────────────────────────────
class PowerService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool canSuspend   READ canSuspend   NOTIFY capsChanged)
    Q_PROPERTY(bool canHibernate READ canHibernate NOTIFY capsChanged)
    Q_PROPERTY(bool canReboot    READ canReboot    NOTIFY capsChanged)
    Q_PROPERTY(bool canShutdown  READ canShutdown  NOTIFY capsChanged)

public:
    explicit PowerService(QObject *parent = nullptr);
    ~PowerService() override;

    bool canSuspend()   const { return m_canSuspend; }
    bool canHibernate() const { return m_canHibernate; }
    bool canReboot()    const { return m_canReboot; }
    bool canShutdown()  const { return m_canShutdown; }

public slots:
    Q_INVOKABLE void lock();
    Q_INVOKABLE void logout();
    Q_INVOKABLE void suspend();
    Q_INVOKABLE void hibernate();
    Q_INVOKABLE void reboot();
    Q_INVOKABLE void shutdown();

signals:
    void capsChanged();

private:
    void queryCaps();
    void callLogind(const QString &method, bool interactive = false);

    bool m_canSuspend   = false;
    bool m_canHibernate = false;
    bool m_canReboot    = false;
    bool m_canShutdown  = false;
};
