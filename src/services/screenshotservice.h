#pragma once

#include <QObject>
#include <QString>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// ScreenshotService — grim/slurp/wf-recorder integration
// ─────────────────────────────────────────────────────────────
class ScreenshotService : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool recording READ recording NOTIFY recordingChanged)

public:
    explicit ScreenshotService(QObject *parent = nullptr);
    ~ScreenshotService() override;

    bool recording() const { return m_recording; }

public slots:
    // Capture the full screen (all outputs) and save to ~/Pictures/Screenshots/
    Q_INVOKABLE void captureFullScreen();

    // Use slurp to let the user select a region, then grim
    Q_INVOKABLE void captureRegion();

    // Capture a specific output by name (e.g. "DP-1")
    Q_INVOKABLE void captureOutput(const QString &outputName);

    // Start/stop screen recording via wf-recorder
    Q_INVOKABLE void startRecording(const QString &outputName = {});
    Q_INVOKABLE void stopRecording();

signals:
    void recordingChanged();
    void screenshotSaved(const QString &path);
    void screenshotFailed(const QString &reason);

private:
    QString buildTimestampedPath(const QString &suffix = {}) const;

    bool     m_recording = false;
    int      m_recorderPid = -1;
};
