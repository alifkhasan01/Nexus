#include "batteryservice.h"
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDebug>

static constexpr char UPOWER_SERVICE[]    = "org.freedesktop.UPower";
static constexpr char UPOWER_PATH[]       = "/org/freedesktop/UPower/devices/DisplayDevice";
static constexpr char UPOWER_IFACE[]      = "org.freedesktop.UPower.Device";
static constexpr char DBUS_PROPS_IFACE[]  = "org.freedesktop.DBus.Properties";

BatteryService::BatteryService(QObject *parent)
    : QObject(parent)
{
    connectUPower();
}

BatteryService::~BatteryService() = default;

void BatteryService::connectUPower()
{
    auto bus = QDBusConnection::systemBus();

    // Listen for property changes on the display device
    bool ok = bus.connect(
        UPOWER_SERVICE,
        UPOWER_PATH,
        DBUS_PROPS_IFACE,
        "PropertiesChanged",
        this,
        SLOT(onUPowerPropertiesChanged(QString, QVariantMap, QStringList))
    );

    if (!ok) {
        qWarning() << "[BatteryService] Failed to connect to UPower PropertiesChanged signal."
                   << "Is UPower running?";
    }

    refreshFromUPower();
}

void BatteryService::refreshFromUPower()
{
    QDBusInterface iface(UPOWER_SERVICE, UPOWER_PATH, DBUS_PROPS_IFACE,
                         QDBusConnection::systemBus());

    if (!iface.isValid()) {
        qWarning() << "[BatteryService] UPower D-Bus interface not available.";
        return;
    }

    auto get = [&](const QString &prop) -> QVariant {
        QDBusReply<QVariant> reply = iface.call("Get", QString(UPOWER_IFACE), prop);
        return reply.isValid() ? reply.value() : QVariant{};
    };

    // Percentage (0–100)
    QVariant pct = get("Percentage");
    if (pct.isValid()) {
        int v = static_cast<int>(pct.toDouble());
        if (m_percentage != v) { m_percentage = v; emit percentageChanged(); }
    }

    // State enum: 1=charging, 2=discharging, 3=empty, 4=full, 5=pending-charge, 6=pending-discharge
    QVariant stateVar = get("State");
    if (stateVar.isValid()) {
        uint s = stateVar.toUInt();
        bool charging  = (s == 1 || s == 5);
        bool pluggedIn = (s == 1 || s == 4 || s == 5);
        QString stateStr;
        switch (s) {
        case 1: stateStr = "charging";   break;
        case 2: stateStr = "discharging"; break;
        case 3: stateStr = "empty";       break;
        case 4: stateStr = "full";        break;
        default: stateStr = "unknown";    break;
        }
        if (m_charging  != charging)  { m_charging  = charging;  emit chargingChanged(); }
        if (m_pluggedIn != pluggedIn) { m_pluggedIn = pluggedIn; emit pluggedInChanged(); }
        if (m_state     != stateStr)  { m_state     = stateStr;  emit stateChanged();    }
    }

    // Time estimates (seconds)
    QVariant tte = get("TimeToEmpty");
    if (tte.isValid()) {
        int v = static_cast<int>(tte.toLongLong());
        if (m_timeToEmpty != v) { m_timeToEmpty = v; emit timeToEmptyChanged(); }
    }
    QVariant ttf = get("TimeToFull");
    if (ttf.isValid()) {
        int v = static_cast<int>(ttf.toLongLong());
        if (m_timeToFull != v) { m_timeToFull = v; emit timeToFullChanged(); }
    }

    QVariant present = get("IsPresent");
    if (present.isValid()) {
        bool v = present.toBool();
        if (m_present != v) { m_present = v; emit presentChanged(); }
    }
}

void BatteryService::onUPowerPropertiesChanged(const QString &,
                                               const QVariantMap &,
                                               const QStringList &)
{
    refreshFromUPower();
}

QString BatteryService::iconName() const
{
    if (!m_present)  return "battery-missing";
    if (m_charging)  return "battery-charging";
    if (m_percentage <= 10) return "battery-caution";
    if (m_percentage <= 30) return "battery-low";
    if (m_percentage <= 60) return "battery-good";
    return "battery-full";
}
