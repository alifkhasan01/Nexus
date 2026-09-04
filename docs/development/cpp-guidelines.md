# C++ Guidelines

## Responsibilities

C++ handles system-facing complexity that QML is not suited for: D-Bus communication, hardware APIs, IPC, compositor integration, and complex state management.

## QML integration

- Inherit `QObject` for all service classes.
- Expose state to QML via `Q_PROPERTY` with `NOTIFY` signals.
- Expose actions via `Q_INVOKABLE` methods or public slots.
- Register services as QML singletons using `qmlRegisterSingletonType` or the CMake `qt_add_qml_module` equivalent.
- Never expose raw pointers to QML; prefer value types or `QObject*` with clear ownership.

## Principles

- Explicit ownership — prefer RAII, use smart pointers (`std::unique_ptr`, `std::shared_ptr`) where ownership is shared or transferred.
- Clear error handling — propagate errors via signals or `Q_PROPERTY` rather than silently failing.
- Small modules — one class per file, one responsibility per class.
- Stable public interfaces — the QML-facing API should change as rarely as possible.
- Non-blocking UI thread — offload blocking I/O to worker threads (`QThread`, `QtConcurrent`) and deliver results via signals.
- Log actionable errors — use `qWarning()` / `qCritical()` with context, not silent returns.
- Prefer native APIs — use Qt wrappers (`QDBusInterface`, `QProcess`, `QNetworkAccessManager`) over spawning raw shell commands when a stable API exists.

## D-Bus

Use `QDBusInterface` or generated adaptor/proxy classes (`qdbusxml2cpp`) for D-Bus communication.
Avoid blocking D-Bus calls on the main thread; use async variants or worker threads.

## Build system

Use CMake with `qt_add_executable` and `qt_add_qml_module`. Keep C++ sources and QML sources in separate directories.

## C++ is not required everywhere

Use C++ where it improves reliability, system integration, or performance. Pure QML is preferred for UI components that do not require system access.
