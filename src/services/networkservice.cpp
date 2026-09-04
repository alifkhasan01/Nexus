#include "networkservice.h"
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDebug>

static constexpr char NM_SERVICE[]     = "org.freedesktop.NetworkManager";
static constexpr char NM_PATH[]        = "/org/freedesktop/NetworkManager";
static constexpr char NM_IFACE[]       = "org.freedesktop.NetworkManager";
static constexpr char DBUS_PROPS_IF[]  = "org.freedesktop.DBus.Properties";

// NM state enum
enum NMState {
    NM_STATE_UNKNOWN          = 0,
    NM_STATE_ASLEEP           = 10,
    NM_STATE_DISCONNECTED     = 20,
    NM_STATE_DISCONNECTING    = 30,
    NM_STATE_CONNECTING       = 40,
    NM_STATE_CONNECTED_LOCAL  = 50,
    NM_STATE_CONNECTED_SITE   = 60,
    NM_STATE_CONNECTED_GLOBAL = 70,
};

// ─────────────────────────────────────────────────────────────
// WifiNetwork
// ─────────────────────────────────────────────────────────────
WifiNetwork::WifiNetwork(const QString &ssid, bool secured, QObject *parent)
    : QObject(parent), m_ssid(ssid), m_secured(secured)
{}

void WifiNetwork::setStrength(int v)
{
    if (m_strength != v) { m_strength = v; emit strengthChanged(); }
}

void WifiNetwork::setConnected(bool v)
{
    if (m_connected != v) { m_connected = v; emit connectedChanged(); }
}

// ─────────────────────────────────────────────────────────────
// NetworkService
// ─────────────────────────────────────────────────────────────
NetworkService::NetworkService(QObject *parent)
    : QObject(parent)
{
    connectNetworkManager();
}

NetworkService::~NetworkService() = default;

void NetworkService::connectNetworkManager()
{
    auto bus = QDBusConnection::systemBus();

    bool ok = bus.connect(
        NM_SERVICE, NM_PATH, NM_IFACE,
        "StateChanged",
        this, SLOT(refreshState())
    );

    if (!ok) {
        qWarning() << "[NetworkService] Could not connect to NetworkManager. Is it running?";
    }

    refreshState();
}

void NetworkService::refreshState()
{
    QDBusInterface propsIface(NM_SERVICE, NM_PATH, DBUS_PROPS_IF,
                              QDBusConnection::systemBus());
    if (!propsIface.isValid()) return;

    // Global connectivity / state
    QDBusReply<QVariant> stateReply = propsIface.call("Get", QString(NM_IFACE), QString("State"));
    if (stateReply.isValid()) {
        uint nmState = stateReply.value().toUInt();
        bool connected = (nmState >= NM_STATE_CONNECTED_LOCAL);
        if (m_connected != connected) { m_connected = connected; emit connectedChanged(); }
    }

    // WirelessEnabled
    QDBusReply<QVariant> wifiReply = propsIface.call("Get", QString(NM_IFACE), QString("WirelessEnabled"));
    if (wifiReply.isValid()) {
        bool v = wifiReply.value().toBool();
        if (m_wifiEnabled != v) { m_wifiEnabled = v; emit wifiEnabledChanged(); }
    }
}

QList<QObject*> NetworkService::networks() const
{
    QList<QObject*> out;
    out.reserve(m_networks.size());
    for (auto *n : m_networks) out.append(n);
    return out;
}

void NetworkService::setWifiEnabled(bool v)
{
    if (m_wifiEnabled == v) return;
    QDBusInterface nm(NM_SERVICE, NM_PATH, NM_IFACE, QDBusConnection::systemBus());
    if (nm.isValid()) {
        nm.call("Set", QString(NM_IFACE), QString("WirelessEnabled"),
                QVariant::fromValue(QDBusVariant(v)));
    }
    m_wifiEnabled = v;
    emit wifiEnabledChanged();
}

void NetworkService::setAirplaneMode(bool v)
{
    if (m_airplaneMode == v) return;
    // Airplane mode disables both WiFi and mobile data
    setWifiEnabled(!v);
    m_airplaneMode = v;
    emit airplaneModeChanged();
}

void NetworkService::connectNetwork(const QString &ssid, const QString &password)
{
    Q_UNUSED(password)
    // TODO: use NM AddAndActivateConnection or ActivateConnection
    qDebug() << "[NetworkService] Connecting to" << ssid;
}

void NetworkService::disconnectNetwork()
{
    // TODO: deactivate active connection via NM D-Bus
    qDebug() << "[NetworkService] Disconnecting";
}

void NetworkService::scanNetworks()
{
    // TODO: request Wi-Fi scan via org.freedesktop.NetworkManager.Device.Wireless.RequestScan
    qDebug() << "[NetworkService] Scan requested";
    emit networksChanged();
}
