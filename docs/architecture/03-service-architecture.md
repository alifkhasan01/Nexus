# Service Architecture

Services are implemented in C++ and exposed to QML via `QObject`-based singletons registered with the QML engine.

Services expose stable, small APIs to the UI.

Recommended services:

- AudioService
- BatteryService
- BluetoothService
- NetworkService
- NotificationService
- MediaService
- PowerService
- WallpaperService
- ScreenshotService
- BrightnessService
- CompositorService

## Example

```qml
Text {
    text: BatteryService.percentage + "%"
}

Button {
    onClicked: PowerService.suspend()
}
```

The UI should not need to know how the service talks to Linux.

## C++ service contract

Each service should:

- inherit `QObject`
- expose properties via `Q_PROPERTY`
- expose actions via `Q_INVOKABLE` methods or slots
- emit signals for state changes
- be registered as a singleton: `qmlRegisterSingletonType` or CMake equivalent
