#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtQuick>

#include "services/audioservice.h"
#include "services/batteryservice.h"
#include "services/bluetoothservice.h"
#include "services/networkservice.h"
#include "services/brightnessservice.h"
#include "services/powerservice.h"
#include "services/screenshotservice.h"
#include "compositor/compositorservice.h"
#include "appindexer/appindexer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("nexus");
    app.setApplicationVersion("0.1.0");
    app.setOrganizationName("nexus");

    // Register C++ singletons with QML
    qmlRegisterSingletonType<AudioService>("Nexus.Services", 1, 0, "AudioService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new AudioService();
        });

    qmlRegisterSingletonType<BatteryService>("Nexus.Services", 1, 0, "BatteryService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new BatteryService();
        });

    qmlRegisterSingletonType<BluetoothService>("Nexus.Services", 1, 0, "BluetoothService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new BluetoothService();
        });

    qmlRegisterSingletonType<NetworkService>("Nexus.Services", 1, 0, "NetworkService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new NetworkService();
        });

    qmlRegisterSingletonType<BrightnessService>("Nexus.Services", 1, 0, "BrightnessService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new BrightnessService();
        });

    qmlRegisterSingletonType<PowerService>("Nexus.Services", 1, 0, "PowerService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new PowerService();
        });

    qmlRegisterSingletonType<ScreenshotService>("Nexus.Services", 1, 0, "ScreenshotService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new ScreenshotService();
        });

    qmlRegisterSingletonType<CompositorService>("Nexus.Services", 1, 0, "CompositorService",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return CompositorService::create();
        });

    qmlRegisterSingletonType<AppIndexer>("Nexus.Services", 1, 0, "AppIndexer",
        [](QQmlEngine *, QJSEngine *) -> QObject * {
            return new AppIndexer();
        });

    QQmlApplicationEngine engine;

    const QUrl entryUrl(u"qrc:/nexus/qml/shell.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [entryUrl](QObject *obj, const QUrl &url) {
            if (!obj && url == entryUrl) {
                QCoreApplication::exit(-1);
            }
        }, Qt::QueuedConnection);

    engine.load(entryUrl);
    return app.exec();
}
