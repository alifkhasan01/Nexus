#pragma once

#include <QObject>
#include <QList>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// WifiNetwork — a visible access point
// ─────────────────────────────────────────────────────────────
class WifiNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ssid      READ ssid      CONSTANT)
    Q_PROPERTY(int     strength  READ strength  NOTIFY strengthChanged)
    Q_PROPERTY(bool    secured   READ secured   CONSTANT)
    Q_PROPERTY(bool    connected READ connected NOTIFY connectedChanged)

public:
    explicit WifiNetwork(const QString &ssid, bool secured, QObject *parent = nullptr);

    QString ssid()      const { return m_ssid; }
    int     strength()  const { return m_strength; }
    bool    secured()   const { return m_secured; }
    bool    connected() const { return m_connected; }

    void setStrength(int v);
    void setConnected(bool v);

signals:
    void strengthChanged();
    void connectedChanged();

private:
    QString m_ssid;
    int     m_strength  = 0;
    bool    m_secured   = false;
    bool    m_connected = false;
};

// ─────────────────────────────────────────────────────────────
// NetworkService — NetworkManager D-Bus integration
// ─────────────────────────────────────────────────────────────
class NetworkService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool    wifiEnabled      READ wifiEnabled    WRITE setWifiEnabled    NOTIFY wifiEnabledChanged)
    Q_PROPERTY(bool    airplaneMode     READ airplaneMode   WRITE setAirplaneMode   NOTIFY airplaneModeChanged)
    Q_PROPERTY(bool    connected        READ connected                              NOTIFY connectedChanged)
    Q_PROPERTY(QString connectedSsid    READ connectedSsid                          NOTIFY connectedSsidChanged)
    Q_PROPERTY(int     signalStrength   READ signalStrength                         NOTIFY signalStrengthChanged)
    Q_PROPERTY(QList<QObject*> networks READ networks                               NOTIFY networksChanged)

public:
    explicit NetworkService(QObject *parent = nullptr);
    ~NetworkService() override;

    bool    wifiEnabled()    const { return m_wifiEnabled; }
    bool    airplaneMode()   const { return m_airplaneMode; }
    bool    connected()      const { return m_connected; }
    QString connectedSsid()  const { return m_connectedSsid; }
    int     signalStrength() const { return m_signalStrength; }
    QList<QObject*> networks() const;

    void setWifiEnabled(bool v);
    void setAirplaneMode(bool v);

public slots:
    Q_INVOKABLE void connectNetwork(const QString &ssid, const QString &password = {});
    Q_INVOKABLE void disconnectNetwork();
    Q_INVOKABLE void scanNetworks();

signals:
    void wifiEnabledChanged();
    void airplaneModeChanged();
    void connectedChanged();
    void connectedSsidChanged();
    void signalStrengthChanged();
    void networksChanged();

private:
    void connectNetworkManager();
    void refreshState();

    bool    m_wifiEnabled    = true;
    bool    m_airplaneMode   = false;
    bool    m_connected      = false;
    QString m_connectedSsid;
    int     m_signalStrength = 0;

    QList<WifiNetwork*> m_networks;
};
