#include "bluetoothservice.h"
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QDBusObjectPath>
#include <QVariantMap>
#include <QDebug>

static constexpr char BLUEZ_SERVICE[]   = "org.bluez";
static constexpr char BLUEZ_ADAPTER[]   = "/org/bluez/hci0";
static constexpr char BLUEZ_ADAPTER_IF[]= "org.bluez.Adapter1";
static constexpr char BLUEZ_DEVICE_IF[] = "org.bluez.Device1";
static constexpr char DBUS_PROPS_IFACE[]= "org.freedesktop.DBus.Properties";
static constexpr char DBUS_OBJMGR[]     = "org.freedesktop.DBus.ObjectManager";

// ─────────────────────────────────────────────────────────────
// BluetoothDevice
// ─────────────────────────────────────────────────────────────
BluetoothDevice::BluetoothDevice(const QString &address, const QString &name, QObject *parent)
    : QObject(parent), m_address(address), m_name(name)
{}

void BluetoothDevice::setName(const QString &v)      { if (m_name      != v) { m_name      = v; emit nameChanged();      } }
void BluetoothDevice::setPaired(bool v)              { if (m_paired    != v) { m_paired    = v; emit pairedChanged();    } }
void BluetoothDevice::setConnected(bool v)           { if (m_connected != v) { m_connected = v; emit connectedChanged(); } }
void BluetoothDevice::setIcon(const QString &v)      { if (m_icon      != v) { m_icon      = v; emit iconChanged();      } }

// ─────────────────────────────────────────────────────────────
// BluetoothService
// ─────────────────────────────────────────────────────────────
BluetoothService::BluetoothService(QObject *parent)
    : QObject(parent)
{
    connectBlueZ();
}

BluetoothService::~BluetoothService() = default;

void BluetoothService::connectBlueZ()
{
    // Read initial adapter powered state
    QDBusInterface propsIface(BLUEZ_SERVICE, BLUEZ_ADAPTER, DBUS_PROPS_IFACE,
                              QDBusConnection::systemBus());
    if (propsIface.isValid()) {
        QDBusReply<QVariant> reply = propsIface.call("Get",
            QString(BLUEZ_ADAPTER_IF), QString("Powered"));
        if (reply.isValid()) {
            m_powered = reply.value().toBool();
        }
    } else {
        qWarning() << "[BluetoothService] BlueZ not available on D-Bus."
                   << "Is bluetoothd running?";
        return;
    }

    // Connect to property changes on the adapter
    QDBusConnection::systemBus().connect(
        BLUEZ_SERVICE, BLUEZ_ADAPTER, DBUS_PROPS_IFACE,
        "PropertiesChanged",
        this, SLOT(onAdapterPropertiesChanged(QString, QVariantMap, QStringList))
    );

    // Enumerate existing paired devices via ObjectManager
    QDBusInterface objMgr(BLUEZ_SERVICE, "/", DBUS_OBJMGR,
                          QDBusConnection::systemBus());
    if (!objMgr.isValid()) return;

    QDBusReply<QVariantMap> objects = objMgr.call("GetManagedObjects");
    // Real implementation iterates objects and extracts Device1 entries.
    // Stub: leave device list empty — devices appear when discovery runs.
}

QList<QObject*> BluetoothService::devices() const
{
    QList<QObject*> out;
    out.reserve(m_devices.size());
    for (auto *d : m_devices) out.append(d);
    return out;
}

void BluetoothService::setPowered(bool v)
{
    if (m_powered == v) return;

    QDBusInterface propsIface(BLUEZ_SERVICE, BLUEZ_ADAPTER, DBUS_PROPS_IFACE,
                              QDBusConnection::systemBus());
    if (propsIface.isValid()) {
        propsIface.call("Set", QString(BLUEZ_ADAPTER_IF),
                        QString("Powered"), QVariant::fromValue(QDBusVariant(v)));
    }
    m_powered = v;
    emit poweredChanged();
}

void BluetoothService::startDiscovery()
{
    if (!m_powered || m_discovering) return;
    QDBusInterface adapter(BLUEZ_SERVICE, BLUEZ_ADAPTER, BLUEZ_ADAPTER_IF,
                           QDBusConnection::systemBus());
    if (adapter.isValid()) adapter.call("StartDiscovery");
    m_discovering = true;
    emit discoveringChanged();
}

void BluetoothService::stopDiscovery()
{
    if (!m_discovering) return;
    QDBusInterface adapter(BLUEZ_SERVICE, BLUEZ_ADAPTER, BLUEZ_ADAPTER_IF,
                           QDBusConnection::systemBus());
    if (adapter.isValid()) adapter.call("StopDiscovery");
    m_discovering = false;
    emit discoveringChanged();
}

void BluetoothService::connectDevice(const QString &address)
{
    BluetoothDevice *dev = deviceByAddress(address);
    if (!dev) return;
    QString path = "/org/bluez/hci0/dev_" + QString(address).replace(':', '_');
    QDBusInterface iface(BLUEZ_SERVICE, path, BLUEZ_DEVICE_IF,
                         QDBusConnection::systemBus());
    if (iface.isValid()) iface.asyncCall("Connect");
}

void BluetoothService::disconnectDevice(const QString &address)
{
    BluetoothDevice *dev = deviceByAddress(address);
    if (!dev) return;
    QString path = "/org/bluez/hci0/dev_" + QString(address).replace(':', '_');
    QDBusInterface iface(BLUEZ_SERVICE, path, BLUEZ_DEVICE_IF,
                         QDBusConnection::systemBus());
    if (iface.isValid()) iface.asyncCall("Disconnect");
}

void BluetoothService::removeDevice(const QString &address)
{
    BluetoothDevice *dev = deviceByAddress(address);
    if (!dev) return;
    QString path = "/org/bluez/hci0/dev_" + QString(address).replace(':', '_');
    QDBusInterface adapter(BLUEZ_SERVICE, BLUEZ_ADAPTER, BLUEZ_ADAPTER_IF,
                           QDBusConnection::systemBus());
    if (adapter.isValid()) adapter.asyncCall("RemoveDevice", QVariant::fromValue(QDBusObjectPath(path)));
    m_devices.removeOne(dev);
    dev->deleteLater();
    emit devicesChanged();
}

BluetoothDevice* BluetoothService::deviceByAddress(const QString &address) const
{
    for (auto *d : m_devices) {
        if (d->address() == address) return d;
    }
    return nullptr;
}
