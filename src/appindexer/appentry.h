#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <qqml.h>

// ─────────────────────────────────────────────────────────────
// AppEntry — parsed representation of an XDG .desktop file
// ─────────────────────────────────────────────────────────────
class AppEntry : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id          READ id          CONSTANT)
    Q_PROPERTY(QString name        READ name        CONSTANT)
    Q_PROPERTY(QString genericName READ genericName CONSTANT)
    Q_PROPERTY(QString comment     READ comment     CONSTANT)
    Q_PROPERTY(QString exec        READ exec        CONSTANT)
    Q_PROPERTY(QString icon        READ icon        CONSTANT)
    Q_PROPERTY(QString iconPath    READ iconPath    CONSTANT)
    Q_PROPERTY(QString category    READ category    CONSTANT)
    Q_PROPERTY(QStringList keywords READ keywords   CONSTANT)
    Q_PROPERTY(bool    terminal    READ terminal    CONSTANT)
    Q_PROPERTY(bool    noDisplay   READ noDisplay   CONSTANT)
    Q_PROPERTY(int     launchCount READ launchCount NOTIFY launchCountChanged)

public:
    explicit AppEntry(QObject *parent = nullptr) : QObject(parent) {}

    QString    id()          const { return m_id; }
    QString    name()        const { return m_name; }
    QString    genericName() const { return m_genericName; }
    QString    comment()     const { return m_comment; }
    QString    exec()        const { return m_exec; }
    QString    icon()        const { return m_icon; }
    QString    iconPath()    const { return m_iconPath; }
    QString    category()    const { return m_category; }
    QStringList keywords()   const { return m_keywords; }
    bool       terminal()    const { return m_terminal; }
    bool       noDisplay()   const { return m_noDisplay; }
    int        launchCount() const { return m_launchCount; }

    void setId(const QString &v)          { m_id          = v; }
    void setName(const QString &v)        { m_name        = v; }
    void setGenericName(const QString &v) { m_genericName = v; }
    void setComment(const QString &v)     { m_comment     = v; }
    void setExec(const QString &v)        { m_exec        = v; }
    void setIcon(const QString &v)        { m_icon        = v; }
    void setIconPath(const QString &v)    { m_iconPath    = v; }
    void setCategory(const QString &v)    { m_category    = v; }
    void setKeywords(const QStringList &v){ m_keywords    = v; }
    void setTerminal(bool v)              { m_terminal    = v; }
    void setNoDisplay(bool v)             { m_noDisplay   = v; }

    void incrementLaunchCount() {
        ++m_launchCount;
        emit launchCountChanged();
    }

    // Fuzzy match score (higher = better match)
    int matchScore(const QString &query) const;

signals:
    void launchCountChanged();

private:
    QString     m_id;
    QString     m_name;
    QString     m_genericName;
    QString     m_comment;
    QString     m_exec;
    QString     m_icon;
    QString     m_iconPath;
    QString     m_category;
    QStringList m_keywords;
    bool        m_terminal  = false;
    bool        m_noDisplay = false;
    int         m_launchCount = 0;
};
