#include "appindexer.h"
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSettings>
#include <QStandardPaths>
#include <QProcessEnvironment>
#include <QProcess>
#include <QIcon>
#include <QtConcurrent>
#include <algorithm>
#include <QDebug>

// ─────────────────────────────────────────────────────────────
// AppIndexer
// ─────────────────────────────────────────────────────────────
AppIndexer::AppIndexer(QObject *parent)
    : QObject(parent)
{
    connect(&m_watcher, &QFileSystemWatcher::directoryChanged,
            this, &AppIndexer::refresh);

    refresh();
}

AppIndexer::~AppIndexer() = default;

QStringList AppIndexer::xdgAppDirs() const
{
    QStringList dirs;

    // $XDG_DATA_HOME/applications
    QString dataHome = QProcessEnvironment::systemEnvironment().value(
        "XDG_DATA_HOME",
        QDir::homePath() + "/.local/share"
    );
    dirs << dataHome + "/applications";

    // Each path in $XDG_DATA_DIRS
    QString xdgDataDirs = QProcessEnvironment::systemEnvironment().value(
        "XDG_DATA_DIRS",
        "/usr/local/share:/usr/share"
    );
    for (const QString &base : xdgDataDirs.split(':', Qt::SkipEmptyParts)) {
        dirs << base + "/applications";
    }

    return dirs;
}

void AppIndexer::refresh()
{
    if (m_loading) return;
    m_loading = true;
    emit loadingChanged();

    // Run on a thread so QML stays responsive
    QtConcurrent::run([this]() {
        QStringList appDirs = xdgAppDirs();
        QList<AppEntry*> entries;
        QSet<QString> seenIds;

        for (const QString &dir : appDirs) {
            QDir d(dir);
            if (!d.exists()) continue;

            m_watcher.addPath(dir);

            for (const QString &file : d.entryList({"*.desktop"}, QDir::Files)) {
                AppEntry *entry = parseDesktopFile(d.filePath(file));
                if (!entry) continue;
                if (entry->noDisplay()) { delete entry; continue; }
                if (seenIds.contains(entry->id())) { delete entry; continue; }
                seenIds.insert(entry->id());
                entries.append(entry);
            }
        }

        // Sort alphabetically
        std::sort(entries.begin(), entries.end(),
            [](const AppEntry *a, const AppEntry *b) {
                return a->name().toLower() < b->name().toLower();
            });

        // Transfer to main thread
        QMetaObject::invokeMethod(this, [this, entries]() {
            qDeleteAll(m_apps);
            m_apps.clear();
            m_apps = entries;
            for (auto *e : m_apps) e->setParent(this);
            m_loading = false;
            emit loadingChanged();
            emit appsChanged();
            qDebug() << "[AppIndexer] Indexed" << m_apps.size() << "applications";
        }, Qt::QueuedConnection);
    });
}

AppEntry* AppIndexer::parseDesktopFile(const QString &path) const
{
    // QSettings parses INI-style files; .desktop files are INI-compatible
    QSettings s(path, QSettings::IniFormat);
    s.beginGroup("Desktop Entry");

    QString type = s.value("Type").toString();
    if (type != "Application") return nullptr;

    auto *entry = new AppEntry();
    entry->setId(QFileInfo(path).baseName());
    entry->setName(s.value("Name").toString());
    entry->setGenericName(s.value("GenericName").toString());
    entry->setComment(s.value("Comment").toString());
    entry->setExec(s.value("Exec").toString());
    entry->setIcon(s.value("Icon").toString());
    entry->setCategory(s.value("Categories").toString().split(';', Qt::SkipEmptyParts).value(0));
    entry->setKeywords(s.value("Keywords").toString().split(';', Qt::SkipEmptyParts));
    entry->setTerminal(s.value("Terminal", false).toBool());
    entry->setNoDisplay(s.value("NoDisplay", false).toBool());

    // Resolve icon path
    if (!entry->icon().isEmpty()) {
        entry->setIconPath(resolveIconPath(entry->icon()));
    }

    s.endGroup();
    return entry;
}

QString AppIndexer::resolveIconPath(const QString &iconName) const
{
    // If it's already an absolute path, use it directly
    if (iconName.startsWith('/') && QFile::exists(iconName)) {
        return iconName;
    }

    // Try QIcon::fromTheme — returns the path if the icon is found
    QIcon icon = QIcon::fromTheme(iconName);
    if (!icon.isNull()) {
        // Get the best available size path
        const auto sizes = icon.availableSizes();
        if (!sizes.isEmpty()) {
            // QIcon doesn't expose the file path directly; return the icon name
            // for QML to resolve via Image { source: "image://theme/<name>" }
            return "image://theme/" + iconName;
        }
    }

    // Fallback: search common icon paths
    const QStringList searchPaths = {
        "/usr/share/pixmaps",
        "/usr/share/icons/hicolor/48x48/apps",
        "/usr/share/icons/hicolor/scalable/apps",
    };
    const QStringList exts = {".png", ".svg", ".xpm"};
    for (const QString &dir : searchPaths) {
        for (const QString &ext : exts) {
            QString candidate = dir + "/" + iconName + ext;
            if (QFile::exists(candidate)) return candidate;
        }
    }

    return {};
}

QList<QObject*> AppIndexer::apps() const
{
    QList<QObject*> out;
    out.reserve(m_apps.size());
    for (auto *e : m_apps) out.append(e);
    return out;
}

QList<QObject*> AppIndexer::search(const QString &query, int maxResults) const
{
    if (query.trimmed().isEmpty()) {
        // Return most-recently-used apps when query is empty
        return recentApps(maxResults);
    }

    // Score each entry
    QList<QPair<int, AppEntry*>> scored;
    scored.reserve(m_apps.size());
    for (auto *e : m_apps) {
        int score = e->matchScore(query);
        if (score > 0) scored.append({score, e});
    }

    // Sort by score descending
    std::sort(scored.begin(), scored.end(),
        [](const QPair<int,AppEntry*> &a, const QPair<int,AppEntry*> &b) {
            return a.first > b.first;
        });

    QList<QObject*> results;
    int limit = qMin(maxResults, scored.size());
    results.reserve(limit);
    for (int i = 0; i < limit; ++i) {
        results.append(scored[i].second);
    }
    return results;
}

QList<QObject*> AppIndexer::recentApps(int count) const
{
    QList<AppEntry*> sorted = m_apps;
    std::sort(sorted.begin(), sorted.end(),
        [](const AppEntry *a, const AppEntry *b) {
            return a->launchCount() > b->launchCount();
        });

    QList<QObject*> out;
    int limit = qMin(count, sorted.size());
    out.reserve(limit);
    for (int i = 0; i < limit; ++i) {
        // Only include apps that have been launched at least once
        if (sorted[i]->launchCount() > 0) out.append(sorted[i]);
    }

    // If not enough recent apps, pad with first alphabetical entries
    for (int i = 0; i < m_apps.size() && out.size() < limit; ++i) {
        if (!out.contains(m_apps[i])) out.append(m_apps[i]);
    }

    return out;
}

void AppIndexer::launch(const QString &id)
{
    AppEntry *entry = nullptr;
    for (auto *e : m_apps) {
        if (e->id() == id) { entry = e; break; }
    }
    if (!entry) {
        emit launchFailed(id, "App not found");
        return;
    }

    // Strip field codes from Exec (%u, %f, %F, %U, etc.)
    QString exec = entry->exec();
    exec.remove(QRegularExpression("%[uUfFdDnNickvm]"));
    exec = exec.trimmed();

    QStringList args = QProcess::splitCommand(exec);
    if (args.isEmpty()) {
        emit launchFailed(id, "Empty exec command");
        return;
    }

    QString program = args.takeFirst();

    if (entry->terminal()) {
        // Launch in terminal (try common emulators)
        QStringList terminals = {"foot", "alacritty", "kitty", "wezterm", "xterm"};
        bool started = false;
        for (const QString &term : terminals) {
            QStringList termArgs = {"-e", program};
            termArgs.append(args);
            if (QProcess::startDetached(term, termArgs)) {
                started = true; break;
            }
        }
        if (!started) emit launchFailed(id, "No terminal emulator found");
    } else {
        if (!QProcess::startDetached(program, args)) {
            emit launchFailed(id, QString("Failed to start: %1").arg(program));
            return;
        }
    }

    entry->incrementLaunchCount();
    emit launchStarted(id);
}
