pragma Singleton
import QtQuick

// ─────────────────────────────────────────────────────────────
// Theme — central design token registry
//
// All QML components must reference tokens from here instead of
// using arbitrary color literals, font sizes, or spacing values.
// ─────────────────────────────────────────────────────────────
QtObject {

    // ── Color roles ─────────────────────────────────────────

    // Backgrounds
    readonly property color background:       "#0f0f11"
    readonly property color surface:          "#1a1a1e"
    readonly property color surfaceElevated:  "#242428"
    readonly property color surfaceHighlight: "#2e2e34"

    // Text
    readonly property color text:             "#f0f0f2"
    readonly property color textSecondary:    "#9494a0"
    readonly property color textDisabled:     "#4e4e58"

    // Accent (blue / macOS-like)
    readonly property color accent:           "#3b82f6"
    readonly property color accentHover:      "#60a5fa"
    readonly property color accentPressed:    "#2563eb"

    // Semantic
    readonly property color success:          "#22c55e"
    readonly property color warning:          "#f59e0b"
    readonly property color error:            "#ef4444"
    readonly property color info:             "#38bdf8"

    // Chrome / structural
    readonly property color border:           "#2e2e38"
    readonly property color borderFocus:      "#3b82f6"
    readonly property color overlay:          "#00000099"
    readonly property color scrim:            "#000000cc"

    // Glass / blur panels
    readonly property color glass:            "#1a1a1e"
    readonly property real  glassOpacity:     0.82

    // ── Typography ──────────────────────────────────────────

    readonly property string fontFamily:      "Inter"
    readonly property string fontFamilyMono:  "JetBrains Mono"

    // Weights
    readonly property int weightRegular:  400
    readonly property int weightMedium:   500
    readonly property int weightSemibold: 600
    readonly property int weightBold:     700

    // Display / hero
    readonly property int sizeDisplay:    32
    readonly property int sizeTitle:      22
    readonly property int sizeSubtitle:   17

    // Body
    readonly property int sizeBody:       14
    readonly property int sizeBodySmall:  13

    // Supporting
    readonly property int sizeCaption:    11
    readonly property int sizeLabel:      12

    // Line heights (multiplier)
    readonly property real lineHeightTight:  1.2
    readonly property real lineHeightNormal: 1.5
    readonly property real lineHeightLoose:  1.75

    // ── Spacing scale ────────────────────────────────────────
    //  xs=4  sm=8  md=12  lg=16  xl=24  xxl=32

    readonly property int spacingXxs:  2
    readonly property int spacingXs:   4
    readonly property int spacingSm:   8
    readonly property int spacingMd:  12
    readonly property int spacingLg:  16
    readonly property int spacingXl:  24
    readonly property int spacingXxl: 32
    readonly property int spacingHuge:48

    // ── Border radius ────────────────────────────────────────

    readonly property int radiusXs:   4
    readonly property int radiusSm:   6
    readonly property int radiusMd:  10
    readonly property int radiusLg:  14
    readonly property int radiusXl:  18
    readonly property int radiusFull: 9999

    // ── Elevation / shadow ───────────────────────────────────

    // Expressed as QML-compatible shadow descriptions (used by ShaderEffect or
    // Rectangle.layer.effect in consuming components).
    readonly property var shadowSm:  ({ blur: 4,  yOffset: 2, color: "#22000000" })
    readonly property var shadowMd:  ({ blur: 12, yOffset: 4, color: "#33000000" })
    readonly property var shadowLg:  ({ blur: 24, yOffset: 8, color: "#44000000" })
    readonly property var shadowXl:  ({ blur: 40, yOffset: 16, color: "#55000000" })

    // ── Borders ──────────────────────────────────────────────

    readonly property int   borderThin:   1
    readonly property int   borderMedium: 1
    readonly property color borderSubtle: "#22ffffff"

    // ── Animation ────────────────────────────────────────────

    // Durations (ms)
    readonly property int durationFast:   100
    readonly property int durationNormal: 200
    readonly property int durationSlow:   350
    readonly property int durationSlower: 500

    // Easing curves
    readonly property int easingStandard:   Easing.OutCubic
    readonly property int easingDecelerate: Easing.OutQuart
    readonly property int easingAccelerate: Easing.InCubic
    readonly property int easingSpring:     Easing.OutBack

    // Reduced-motion support — components should check this flag
    // and replace motion with instant state changes when true.
    readonly property bool reducedMotion: false

    // ── Icon sizes ───────────────────────────────────────────

    readonly property int iconXs:   12
    readonly property int iconSm:   16
    readonly property int iconMd:   20
    readonly property int iconLg:   24
    readonly property int iconXl:   32
    readonly property int iconHuge: 48

    // ── Component-level shortcuts ────────────────────────────

    // Bar
    readonly property int barHeight: 32

    // Dock
    readonly property int dockIconSize:   52
    readonly property int dockIconSizeMd: 44
    readonly property int dockPadding:    8

    // OSD
    readonly property int osdWidth:  260
    readonly property int osdHeight: 52
}
