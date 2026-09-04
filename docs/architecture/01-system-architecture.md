# System Architecture

## High-level model

```text
QuickShell / QML
       |
       | bindings / service API
       v
C++ Backend + Services
       |
   +---+-------------------+
   |           |           |
Wayland      D-Bus      PipeWire
   |           |           |
Compositor  System      Audio
```

## Responsibility split

### QML

Responsible for:

- layout
- rendering
- animation
- visual state
- user interaction
- composition of reusable components

### C++ Backend

Responsible for:

- system integration
- IPC
- D-Bus
- process management
- caching
- hardware/system state
- compositor integration
- complex business logic

## Rule

Avoid embedding complex shell commands or system logic directly inside UI event handlers. Delegate that work to C++ backend services exposed to QML.
