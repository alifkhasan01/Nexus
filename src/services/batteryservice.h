#pragma once

#include <QObject>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// BatteryService — UPower D-Bus integration
// ─────────────────────────────────────────────────────────────
class BatteryService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int     percentage      READ percentage      NOTIFY percentageChanged)
    Q_PROPERTY(bool    charging        READ charging        NOTIFY chargingChanged)
    Q_PROPERTY(bool    pluggedIn       READ pluggedIn       NOTIFY pluggedInChanged)
    Q_PROPERTY(QString state           READ state           NOTIFY stateChanged)
    Q_PROPERTY(int     timeToEmpty     READ timeToEmpty     NOTIFY timeToEmptyChanged)
    Q_PROPERTY(int     timeToFull      READ timeToFull      NOTIFY timeToFullChanged)
    Q_PROPERTY(bool    present         READ present         NOTIFY presentChanged)

public:
    explicit BatteryService(QObject *parent = nullptr);
    ~BatteryService() override;

    int     percentage()  const { return m_percentage; }
    bool    charging()    const { return m_charging; }
    bool    pluggedIn()   const { return m_pluggedIn; }
    QString state()       const { return m_state; }
    int     timeToEmpty() const { return m_timeToEmpty; }   // seconds
    int     timeToFull()  const { return m_timeToFull; }    // seconds
    bool    present()     const { return m_present; }

    // Convenience: icon name based on current state
    Q_INVOKABLE QString iconName() const;

signals:
    void percentageChanged();
    void chargingChanged();
    void pluggedInChanged();
    void stateChanged();
    void timeToEmptyChanged();
    void timeToFullChanged();
    void presentChanged();

private slots:
    void onUPowerPropertiesChanged(const QString &interface,
                                   const QVariantMap &changed,
                                   const QStringList &invalidated);

private:
    void connectUPower();
    void refreshFromUPower();

    int     m_percentage  = 100;
    bool    m_charging    = false;
    bool    m_pluggedIn   = true;
    QString m_state       = "full";
    int     m_timeToEmpty = 0;
    int     m_timeToFull  = 0;
    bool    m_present     = true;
};
