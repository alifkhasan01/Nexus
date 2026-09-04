# Module Architecture

Each major visual feature should be isolated.

```text
modules/
├── bar/
├── dock/
├── launcher/
├── overview/
├── control-center/
├── notifications/
├── osd/
├── media/
├── wallpaper/
└── settings/
```

A module may contain:

- root component
- child components
- models
- animations
- module-specific helpers
- documentation

Modules should depend on shared components and services, not on unrelated modules.
