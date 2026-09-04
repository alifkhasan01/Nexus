#pragma once

#include <QObject>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// BrightnessService — logind D-Bus / sysfs backlight integration
// ─────────────────────────────────────────────────────────────
class BrightnessService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(int  brightness    READ brightness    WRITE setBrightness    NOTIFY brightnessChanged)
    Q_PROPERTY(int  maxBrightness READ maxBrightness                        NOTIFY maxBrightnessChanged)
    Q_PROPERTY(real percent       READ percent                               NOTIFY brightnessChanged)

public:
    explicit BrightnessService(QObject *parent = nullptr);
    ~BrightnessService() override;

    int  brightness()    const { return m_brightness; }
    int  maxBrightness() const { return m_maxBrightness; }
    real percent()       const {
        return m_maxBrightness > 0
            ? static_cast<real>(m_brightness) / m_maxBrightness
            : 0.0;
    }

    void setBrightness(int v);

public slots:
    Q_INVOKABLE void increase(int step = 10);
    Q_INVOKABLE void decrease(int step = 10);
    Q_INVOKABLE void setPercent(real p);

signals:
    void brightnessChanged();
    void maxBrightnessChanged();

private:
    void discoverBacklight();
    void readCurrent();
    void applyBrightness(int v);

    QString m_backlightDevice;    // e.g. "intel_backlight"
    bool    m_useLogind = false;  // prefer logind D-Bus over direct sysfs write

    int  m_brightness    = 100;
    int  m_maxBrightness = 100;
};
