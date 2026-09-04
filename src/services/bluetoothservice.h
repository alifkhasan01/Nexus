#pragma once

#include <QObject>
#include <QList>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// BluetoothDevice — a single paired or discovered device
// ─────────────────────────────────────────────────────────────
class BluetoothDevice : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString  address   READ address   CONSTANT)
    Q_PROPERTY(QString  name      READ name      NOTIFY nameChanged)
    Q_PROPERTY(bool     paired    READ paired    NOTIFY pairedChanged)
    Q_PROPERTY(bool     connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString  icon      READ icon      NOTIFY iconChanged)

public:
    explicit BluetoothDevice(const QString &address, const QString &name,
                              QObject *parent = nullptr);

    QString address()   const { return m_address; }
    QString name()      const { return m_name; }
    bool    paired()    const { return m_paired; }
    bool    connected() const { return m_connected; }
    QString icon()      const { return m_icon; }

    void setName(const QString &v);
    void setPaired(bool v);
    void setConnected(bool v);
    void setIcon(const QString &v);

signals:
    void nameChanged();
    void pairedChanged();
    void connectedChanged();
    void iconChanged();

private:
    QString m_address;
    QString m_name;
    bool    m_paired    = false;
    bool    m_connected = false;
    QString m_icon      = "bluetooth";
};

// ─────────────────────────────────────────────────────────────
// BluetoothService — BlueZ D-Bus integration
// ─────────────────────────────────────────────────────────────
class BluetoothService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool    powered     READ powered     WRITE setPowered    NOTIFY poweredChanged)
    Q_PROPERTY(bool    discovering READ discovering                      NOTIFY discoveringChanged)
    Q_PROPERTY(QList<QObject*> devices READ devices                     NOTIFY devicesChanged)

public:
    explicit BluetoothService(QObject *parent = nullptr);
    ~BluetoothService() override;

    bool    powered()     const { return m_powered; }
    bool    discovering() const { return m_discovering; }
    QList<QObject*> devices() const;

    void setPowered(bool v);

public slots:
    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void stopDiscovery();
    Q_INVOKABLE void connectDevice(const QString &address);
    Q_INVOKABLE void disconnectDevice(const QString &address);
    Q_INVOKABLE void removeDevice(const QString &address);

signals:
    void poweredChanged();
    void discoveringChanged();
    void devicesChanged();

private:
    void connectBlueZ();
    BluetoothDevice* deviceByAddress(const QString &address) const;

    bool    m_powered     = false;
    bool    m_discovering = false;
    QList<BluetoothDevice*> m_devices;
};
