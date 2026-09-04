#pragma once

#include "appentry.h"
#include <QObject>
#include <QList>
#include <QString>
#include <QFileSystemWatcher>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// AppIndexer — XDG .desktop file parser and search service
//
// Reads from:
//   $XDG_DATA_HOME/applications      (~/.local/share/applications)
//   Each dir in $XDG_DATA_DIRS        (typically /usr/share/applications)
//
// Exposed to QML as Nexus.Services.AppIndexer
// ─────────────────────────────────────────────────────────────
class AppIndexer : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QList<QObject*> apps    READ apps     NOTIFY appsChanged)
    Q_PROPERTY(bool            loading READ loading  NOTIFY loadingChanged)

public:
    explicit AppIndexer(QObject *parent = nullptr);
    ~AppIndexer() override;

    QList<QObject*> apps()    const;
    bool            loading() const { return m_loading; }

public slots:
    // Search: returns scored/sorted list of matching AppEntry*
    Q_INVOKABLE QList<QObject*> search(const QString &query, int maxResults = 12) const;

    // Launch an app by its id; increments launch count
    Q_INVOKABLE void launch(const QString &id);

    // Trigger a rescan (also called automatically on file changes)
    Q_INVOKABLE void refresh();

    // Recent apps (sorted by launch count, most used first)
    Q_INVOKABLE QList<QObject*> recentApps(int count = 6) const;

signals:
    void appsChanged();
    void loadingChanged();
    void launchStarted(const QString &id);
    void launchFailed(const QString &id, const QString &reason);

private:
    void            scanDirectories();
    AppEntry*       parseDesktopFile(const QString &path) const;
    QString         resolveIconPath(const QString &iconName) const;
    QStringList     xdgAppDirs() const;

    QList<AppEntry*>  m_apps;
    bool              m_loading = false;
    QFileSystemWatcher m_watcher;
};
