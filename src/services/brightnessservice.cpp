#include "brightnessservice.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QTextStream>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDebug>
#include <algorithm>

static constexpr char SYSFS_BACKLIGHT[] = "/sys/class/backlight";
static constexpr char LOGIND_SERVICE[]  = "org.freedesktop.login1";
static constexpr char LOGIND_SESSION[]  = "/org/freedesktop/login1/session/auto";
static constexpr char LOGIND_SESS_IF[]  = "org.freedesktop.login1.Session";

BrightnessService::BrightnessService(QObject *parent)
    : QObject(parent)
{
    discoverBacklight();
    readCurrent();
}

BrightnessService::~BrightnessService() = default;

void BrightnessService::discoverBacklight()
{
    // Try logind first (unprivileged)
    QDBusInterface session(LOGIND_SERVICE, LOGIND_SESSION, LOGIND_SESS_IF,
                           QDBusConnection::systemBus());
    if (session.isValid()) {
        m_useLogind = true;
    }

    // Find first backlight device in sysfs
    QDir bl(SYSFS_BACKLIGHT);
    const QStringList devices = bl.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    if (!devices.isEmpty()) {
        m_backlightDevice = devices.first();
        qDebug() << "[BrightnessService] Found backlight:" << m_backlightDevice
                 << "logind:" << m_useLogind;
    } else {
        qWarning() << "[BrightnessService] No backlight device found in" << SYSFS_BACKLIGHT;
    }
}

void BrightnessService::readCurrent()
{
    if (m_backlightDevice.isEmpty()) return;

    QString base = QString("%1/%2").arg(SYSFS_BACKLIGHT, m_backlightDevice);

    // Max brightness
    QFile maxFile(base + "/max_brightness");
    if (maxFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream ts(&maxFile);
        int v = ts.readLine().trimmed().toInt();
        if (m_maxBrightness != v) {
            m_maxBrightness = v;
            emit maxBrightnessChanged();
        }
    }

    // Current brightness
    QFile curFile(base + "/brightness");
    if (curFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream ts(&curFile);
        int v = ts.readLine().trimmed().toInt();
        if (m_brightness != v) {
            m_brightness = v;
            emit brightnessChanged();
        }
    }
}

void BrightnessService::applyBrightness(int v)
{
    int clamped = std::clamp(v, 1, m_maxBrightness);
    if (m_brightness == clamped) return;
    m_brightness = clamped;

    if (m_useLogind) {
        QDBusInterface session(LOGIND_SERVICE, LOGIND_SESSION, LOGIND_SESS_IF,
                               QDBusConnection::systemBus());
        if (session.isValid()) {
            session.asyncCall("SetBrightness", QString("backlight"),
                              m_backlightDevice, static_cast<uint>(clamped));
            emit brightnessChanged();
            return;
        }
    }

    // Fallback: direct sysfs write (requires write permission)
    QString path = QString("%1/%2/brightness").arg(SYSFS_BACKLIGHT, m_backlightDevice);
    QFile f(path);
    if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream ts(&f);
        ts << clamped;
        emit brightnessChanged();
    } else {
        qWarning() << "[BrightnessService] Cannot write to" << path;
    }
}

void BrightnessService::setBrightness(int v)
{
    applyBrightness(v);
}

void BrightnessService::increase(int step)
{
    applyBrightness(m_brightness + step);
}

void BrightnessService::decrease(int step)
{
    applyBrightness(m_brightness - step);
}

void BrightnessService::setPercent(qreal p)
{
    applyBrightness(static_cast<int>(p * m_maxBrightness));
}
