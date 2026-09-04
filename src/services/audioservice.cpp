#include "audioservice.h"
#include <algorithm>
#include <QDebug>

// ─────────────────────────────────────────────────────────────
// AudioDevice
// ─────────────────────────────────────────────────────────────
AudioDevice::AudioDevice(const QString &id, const QString &name, QObject *parent)
    : QObject(parent), m_id(id), m_name(name)
{}

void AudioDevice::setIsDefault(bool v)
{
    if (m_isDefault == v) return;
    m_isDefault = v;
    emit isDefaultChanged();
}

// ─────────────────────────────────────────────────────────────
// AudioService
// ─────────────────────────────────────────────────────────────
AudioService::AudioService(QObject *parent)
    : QObject(parent)
{
    // TODO: connect to PipeWire / WirePlumber via pw_context / wp_core
    // For now populate with a stub default device so the UI is functional.
    initPipeWire();
}

AudioService::~AudioService() = default;

void AudioService::initPipeWire()
{
    // Stub: add a single default sink and source.
    // Real implementation connects PipeWire's C API through a QThread worker
    // and emits signal updates when devices or volumes change.
    auto *defaultSink = new AudioDevice("default-sink", "Built-in Audio Output", this);
    defaultSink->setIsDefault(true);
    m_sinks.append(defaultSink);

    auto *defaultSrc = new AudioDevice("default-source", "Built-in Microphone", this);
    defaultSrc->setIsDefault(true);
    m_sources.append(defaultSrc);
}

void AudioService::refreshDevices()
{
    emit sinksChanged();
    emit sourcesChanged();
}

QList<QObject*> AudioService::sinks() const
{
    QList<QObject*> out;
    out.reserve(m_sinks.size());
    for (auto *d : m_sinks) out.append(d);
    return out;
}

QList<QObject*> AudioService::sources() const
{
    QList<QObject*> out;
    out.reserve(m_sources.size());
    for (auto *d : m_sources) out.append(d);
    return out;
}

void AudioService::setVolume(int v)
{
    int clamped = std::clamp(v, 0, 150);
    if (m_volume == clamped) return;
    m_volume = clamped;
    // TODO: apply to PipeWire default sink via wp_mixer_api
    emit volumeChanged();
}

void AudioService::setMuted(bool v)
{
    if (m_muted == v) return;
    m_muted = v;
    // TODO: apply mute via WirePlumber mixer API
    emit mutedChanged();
}

void AudioService::setMicVolume(int v)
{
    int clamped = std::clamp(v, 0, 150);
    if (m_micVolume == clamped) return;
    m_micVolume = clamped;
    emit micVolumeChanged();
}

void AudioService::setMicMuted(bool v)
{
    if (m_micMuted == v) return;
    m_micMuted = v;
    emit micMutedChanged();
}

void AudioService::increaseVolume(int step)
{
    setVolume(m_volume + step);
}

void AudioService::decreaseVolume(int step)
{
    setVolume(m_volume - step);
}

void AudioService::toggleMute()
{
    setMuted(!m_muted);
}

void AudioService::toggleMicMute()
{
    setMicMuted(!m_micMuted);
}

void AudioService::setDefaultSink(const QString &id)
{
    for (auto *d : m_sinks) {
        d->setIsDefault(d->id() == id);
    }
    // TODO: apply to PipeWire via WirePlumber default-nodes API
    qDebug() << "[AudioService] default sink set to" << id;
}

void AudioService::setDefaultSource(const QString &id)
{
    for (auto *d : m_sources) {
        d->setIsDefault(d->id() == id);
    }
    qDebug() << "[AudioService] default source set to" << id;
}
