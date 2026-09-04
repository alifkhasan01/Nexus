#include "screenshotservice.h"
#include <QProcess>
#include <QDateTime>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

ScreenshotService::ScreenshotService(QObject *parent)
    : QObject(parent)
{}

ScreenshotService::~ScreenshotService()
{
    if (m_recording) stopRecording();
}

QString ScreenshotService::buildTimestampedPath(const QString &suffix) const
{
    QString dir = QStandardPaths::writableLocation(QStandardPaths::PicturesLocation)
                  + "/Screenshots";
    QDir().mkpath(dir);
    QString ts = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
    return QString("%1/%2%3.png").arg(dir, ts, suffix);
}

void ScreenshotService::captureFullScreen()
{
    QString path = buildTimestampedPath();
    auto *proc = new QProcess(this);
    proc->setProgram("grim");
    proc->setArguments({path});

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, proc, path](int exitCode, QProcess::ExitStatus) {
        if (exitCode == 0) {
            qDebug() << "[ScreenshotService] Saved to" << path;
            emit screenshotSaved(path);
        } else {
            QString err = proc->readAllStandardError();
            qWarning() << "[ScreenshotService] grim failed:" << err;
            emit screenshotFailed(err);
        }
        proc->deleteLater();
    });

    proc->start();
}

void ScreenshotService::captureRegion()
{
    // Chain: slurp → grim -g <region> <path>
    auto *slurp = new QProcess(this);
    slurp->setProgram("slurp");

    connect(slurp, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, slurp](int exitCode, QProcess::ExitStatus) {
        if (exitCode != 0) {
            slurp->deleteLater();
            return; // user cancelled
        }
        QString region = slurp->readAllStandardOutput().trimmed();
        slurp->deleteLater();

        QString path = buildTimestampedPath("_region");
        auto *grim = new QProcess(this);
        grim->setProgram("grim");
        grim->setArguments({"-g", region, path});

        connect(grim, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, [this, grim, path](int ec, QProcess::ExitStatus) {
            if (ec == 0) emit screenshotSaved(path);
            else         emit screenshotFailed(grim->readAllStandardError());
            grim->deleteLater();
        });

        grim->start();
    });

    slurp->start();
}

void ScreenshotService::captureOutput(const QString &outputName)
{
    QString path = buildTimestampedPath("_" + outputName);
    auto *proc = new QProcess(this);
    proc->setProgram("grim");
    proc->setArguments({"-o", outputName, path});

    connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, [this, proc, path](int exitCode, QProcess::ExitStatus) {
        if (exitCode == 0) emit screenshotSaved(path);
        else               emit screenshotFailed(proc->readAllStandardError());
        proc->deleteLater();
    });

    proc->start();
}

void ScreenshotService::startRecording(const QString &outputName)
{
    if (m_recording) return;

    QString dir = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation)
                  + "/Recordings";
    QDir().mkpath(dir);
    QString ts   = QDateTime::currentDateTime().toString("yyyy-MM-dd_HH-mm-ss");
    QString path = QString("%1/%2.mp4").arg(dir, ts);

    QStringList args = {"-f", path};
    if (!outputName.isEmpty()) args << "-o" << outputName;

    auto *proc = new QProcess(this);
    proc->setProgram("wf-recorder");
    proc->setArguments(args);
    proc->start();

    if (proc->waitForStarted(2000)) {
        m_recording   = true;
        m_recorderPid = proc->processId();
        emit recordingChanged();
        qDebug() << "[ScreenshotService] Recording started at" << path;
    } else {
        qWarning() << "[ScreenshotService] wf-recorder failed to start";
        proc->deleteLater();
    }
}

void ScreenshotService::stopRecording()
{
    if (!m_recording) return;

    // Send SIGINT to wf-recorder for a clean finish
    if (m_recorderPid > 0) {
        QProcess::execute("kill", {"-INT", QString::number(m_recorderPid)});
    }

    m_recording   = false;
    m_recorderPid = -1;
    emit recordingChanged();
}
