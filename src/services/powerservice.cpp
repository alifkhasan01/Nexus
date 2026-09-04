#include "powerservice.h"
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QProcess>
#include <QDebug>

static constexpr char LOGIND_SERVICE[]  = "org.freedesktop.login1";
static constexpr char LOGIND_MGR_PATH[] = "/org/freedesktop/login1";
static constexpr char LOGIND_MGR_IF[]   = "org.freedesktop.login1.Manager";

PowerService::PowerService(QObject *parent)
    : QObject(parent)
{
    queryCaps();
}

PowerService::~PowerService() = default;

void PowerService::queryCaps()
{
    QDBusInterface mgr(LOGIND_SERVICE, LOGIND_MGR_PATH, LOGIND_MGR_IF,
                       QDBusConnection::systemBus());
    if (!mgr.isValid()) {
        qWarning() << "[PowerService] logind not available.";
        return;
    }

    auto queryMethod = [&](const QString &method) -> bool {
        QDBusReply<QString> reply = mgr.call(method);
        if (!reply.isValid()) return false;
        QString r = reply.value();
        return (r == "yes" || r == "challenge");
    };

    m_canSuspend   = queryMethod("CanSuspend");
    m_canHibernate = queryMethod("CanHibernate");
    m_canReboot    = queryMethod("CanReboot");
    m_canShutdown  = queryMethod("CanPowerOff");
    emit capsChanged();
}

void PowerService::callLogind(const QString &method, bool interactive)
{
    QDBusInterface mgr(LOGIND_SERVICE, LOGIND_MGR_PATH, LOGIND_MGR_IF,
                       QDBusConnection::systemBus());
    if (mgr.isValid()) {
        mgr.asyncCall(method, interactive);
    } else {
        qWarning() << "[PowerService] Cannot call logind:" << method;
    }
}

void PowerService::lock()
{
    // Try compositor lock first, then logind session lock
    // Hyprland: hyprctl dispatch exec swaylock
    // Generic: loginctl lock-session
    QDBusInterface session(LOGIND_SERVICE, "/org/freedesktop/login1/session/auto",
                           "org.freedesktop.login1.Session",
                           QDBusConnection::systemBus());
    if (session.isValid()) {
        session.asyncCall("Lock");
    } else {
        QProcess::startDetached("loginctl", {"lock-session"});
    }
}

void PowerService::logout()
{
    // Compositor-agnostic: try SIGHUP on compositor process via SIGHUP or ask compositor
    // Fallback: ask session manager
    QProcess::startDetached("loginctl", {"kill-session", "auto"});
}

void PowerService::suspend()
{
    callLogind("Suspend", false);
}

void PowerService::hibernate()
{
    callLogind("Hibernate", false);
}

void PowerService::reboot()
{
    callLogind("Reboot", false);
}

void PowerService::shutdown()
{
    callLogind("PowerOff", false);
}
