# Design System

The shell must use shared design tokens rather than arbitrary values scattered across QML.

```text
Theme
├── colors
├── typography
├── spacing
├── radius
├── elevation
├── borders
├── icons
└── animation
```

Example:

```qml
Theme.background
Theme.surface
Theme.text
Theme.textSecondary
Theme.accent
Theme.radiusMedium
Theme.spacingMedium
```
