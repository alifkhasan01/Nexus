#include "appentry.h"

// ─────────────────────────────────────────────────────────────
// Fuzzy match scoring
//
// Strategy:
//   1. Exact prefix match on name scores highest
//   2. Contains match on name scores high
//   3. Contains match on generic name / keywords scores lower
//   4. Subsequence match scores lowest
// ─────────────────────────────────────────────────────────────
int AppEntry::matchScore(const QString &query) const
{
    if (query.isEmpty()) return 0;

    QString q   = query.toLower();
    QString n   = m_name.toLower();
    QString gn  = m_genericName.toLower();
    QString com = m_comment.toLower();

    // Exact match
    if (n == q) return 1000;

    // Prefix on name
    if (n.startsWith(q)) return 900;

    // Word start match (e.g. "fi" matches "Firefox")
    for (const QString &word : n.split(' ')) {
        if (word.startsWith(q)) return 800;
    }

    // Contains in name
    if (n.contains(q)) return 700;

    // Contains in generic name or comment
    if (gn.contains(q) || com.contains(q)) return 500;

    // Keywords
    for (const QString &kw : m_keywords) {
        if (kw.toLower().contains(q)) return 400;
    }

    // Subsequence match on name
    int qi = 0;
    for (QChar c : n) {
        if (qi < q.size() && c == q[qi]) ++qi;
    }
    if (qi == q.size()) return 200;

    return 0;
}
