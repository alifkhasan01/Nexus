# Coding Style

## QML

QML is responsible for:

- layout
- rendering
- animation
- interaction

Avoid complex system logic in QML.

## C++

C++ is responsible for:

- system integration
- IPC
- D-Bus
- state management
- process management
- compositor backends

C++ backend code should expose a clean QML-facing API via `QObject`, `Q_PROPERTY`, and `Q_INVOKABLE`. Keep platform-specific and system-facing code isolated from the QML-facing interface.

## General

Avoid:

- duplicated logic
- giant files
- unexplained magic values
- unnecessary polling
- unnecessary shell commands
- hidden global state
