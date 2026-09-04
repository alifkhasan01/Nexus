#pragma once

#include <QObject>
#include <QList>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// AudioDevice — represents a single PipeWire sink or source
// ─────────────────────────────────────────────────────────────
class AudioDevice : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id       READ id       CONSTANT)
    Q_PROPERTY(QString name     READ name     CONSTANT)
    Q_PROPERTY(bool    isDefault READ isDefault NOTIFY isDefaultChanged)

public:
    explicit AudioDevice(const QString &id, const QString &name, QObject *parent = nullptr);

    QString id()        const { return m_id; }
    QString name()      const { return m_name; }
    bool    isDefault() const { return m_isDefault; }

    void setIsDefault(bool v);

signals:
    void isDefaultChanged();

private:
    QString m_id;
    QString m_name;
    bool    m_isDefault = false;
};

// ─────────────────────────────────────────────────────────────
// AudioService — PipeWire / WirePlumber audio integration
// Exposed to QML as a singleton via Nexus.Services
// ─────────────────────────────────────────────────────────────
class AudioService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Sink (output) state
    Q_PROPERTY(int     volume          READ volume          WRITE setVolume          NOTIFY volumeChanged)
    Q_PROPERTY(bool    muted           READ muted           WRITE setMuted           NOTIFY mutedChanged)

    // Source (microphone) state
    Q_PROPERTY(int     micVolume       READ micVolume       WRITE setMicVolume       NOTIFY micVolumeChanged)
    Q_PROPERTY(bool    micMuted        READ micMuted        WRITE setMicMuted        NOTIFY micMutedChanged)

    // Device lists
    Q_PROPERTY(QList<QObject*> sinks   READ sinks           NOTIFY sinksChanged)
    Q_PROPERTY(QList<QObject*> sources READ sources         NOTIFY sourcesChanged)

public:
    explicit AudioService(QObject *parent = nullptr);
    ~AudioService() override;

    int  volume()    const { return m_volume; }
    bool muted()     const { return m_muted; }
    int  micVolume() const { return m_micVolume; }
    bool micMuted()  const { return m_micMuted; }

    QList<QObject*> sinks()   const;
    QList<QObject*> sources() const;

    void setVolume(int v);
    void setMuted(bool v);
    void setMicVolume(int v);
    void setMicMuted(bool v);

public slots:
    Q_INVOKABLE void increaseVolume(int step = 5);
    Q_INVOKABLE void decreaseVolume(int step = 5);
    Q_INVOKABLE void toggleMute();
    Q_INVOKABLE void toggleMicMute();
    Q_INVOKABLE void setDefaultSink(const QString &id);
    Q_INVOKABLE void setDefaultSource(const QString &id);

signals:
    void volumeChanged();
    void mutedChanged();
    void micVolumeChanged();
    void micMutedChanged();
    void sinksChanged();
    void sourcesChanged();

private:
    void initPipeWire();
    void refreshDevices();

    int  m_volume    = 50;
    bool m_muted     = false;
    int  m_micVolume = 80;
    bool m_micMuted  = false;

    QList<AudioDevice*> m_sinks;
    QList<AudioDevice*> m_sources;
};
