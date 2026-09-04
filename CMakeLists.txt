cmake_minimum_required(VERSION 3.16)

project(nexus
    VERSION 0.1.0
    DESCRIPTION "A macOS-inspired Wayland desktop shell for Linux"
    LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Qt6 components
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    Qml
    DBus
    Concurrent
    Gui
)

qt_standard_project_setup()

# ──────────────────────────────────────────────
# C++ backend library
# ──────────────────────────────────────────────
add_library(nexus_backend STATIC
    # Services
    src/services/audioservice.cpp
    src/services/batteryservice.cpp
    src/services/bluetoothservice.cpp
    src/services/networkservice.cpp
    src/services/brightnessservice.cpp
    src/services/powerservice.cpp
    src/services/screenshotservice.cpp

    # Compositor
    src/compositor/compositorservice.cpp
    src/compositor/hyprlandbackend.cpp

    # App indexer
    src/appindexer/appindexer.cpp
    src/appindexer/appentry.cpp
)

target_include_directories(nexus_backend PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(nexus_backend PUBLIC
    Qt6::Core
    Qt6::DBus
    Qt6::Concurrent
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
)

# ──────────────────────────────────────────────
# QML module
# ──────────────────────────────────────────────
qt_add_qml_module(nexus_qml
    URI Nexus
    VERSION 1.0
    QML_FILES
        # Shell entry point
        qml/shell.qml

        # Theme
        qml/theme/Theme.qml

        # Shared components
        qml/components/NxButton.qml
        qml/components/NxIconButton.qml
        qml/components/NxCard.qml
        qml/components/NxSlider.qml
        qml/components/NxToggle.qml
        qml/components/NxSeparator.qml
        qml/components/NxTooltip.qml
        qml/components/NxProgressBar.qml
        qml/components/NxPopup.qml
        qml/components/NxScrollView.qml

        # Bar module
        qml/modules/bar/Bar.qml
        qml/modules/bar/WorkspaceIndicator.qml
        qml/modules/bar/ActiveAppLabel.qml
        qml/modules/bar/Clock.qml
        qml/modules/bar/StatusIcons.qml
        qml/modules/bar/SysTray.qml
        qml/modules/bar/BarButton.qml

        # Dock module
        qml/modules/dock/Dock.qml
        qml/modules/dock/DockItem.qml
        qml/modules/dock/DockSeparator.qml
        qml/modules/dock/DockTooltip.qml

        # Launcher module
        qml/modules/launcher/Launcher.qml
        qml/modules/launcher/LauncherSearch.qml
        qml/modules/launcher/LauncherResult.qml
        qml/modules/launcher/LauncherResultItem.qml

        # Overview module
        qml/modules/overview/Overview.qml
        qml/modules/overview/WorkspaceThumb.qml
        qml/modules/overview/WindowThumb.qml

        # Control Center module
        qml/modules/control-center/ControlCenter.qml
        qml/modules/control-center/ControlTile.qml
        qml/modules/control-center/AudioControls.qml
        qml/modules/control-center/NetworkControls.qml
        qml/modules/control-center/BluetoothControls.qml
        qml/modules/control-center/BrightnessControl.qml
        qml/modules/control-center/BatteryInfo.qml
        qml/modules/control-center/MediaCard.qml

        # Notifications module
        qml/modules/notifications/NotificationCenter.qml
        qml/modules/notifications/NotificationItem.qml
        qml/modules/notifications/NotificationBanner.qml
        qml/modules/notifications/NotificationGroup.qml

        # OSD module
        qml/modules/osd/Osd.qml
        qml/modules/osd/OsdBar.qml

        # Media module
        qml/modules/media/MediaPlayer.qml
        qml/modules/media/MediaArtwork.qml
        qml/modules/media/MediaControls.qml
        qml/modules/media/MediaProgress.qml

        # Wallpaper module
        qml/modules/wallpaper/WallpaperPicker.qml
        qml/modules/wallpaper/WallpaperThumb.qml

        # Settings module
        qml/modules/settings/Settings.qml
        qml/modules/settings/SettingsSidebar.qml
        qml/modules/settings/SettingsPage.qml
        qml/modules/settings/pages/AppearancePage.qml
        qml/modules/settings/pages/BarPage.qml
        qml/modules/settings/pages/DockPage.qml
        qml/modules/settings/pages/NotificationsPage.qml
        qml/modules/settings/pages/PowerPage.qml

    RESOURCES
        # qmldir files — needed at runtime for module resolution
        qml/theme/qmldir
        qml/components/qmldir
        qml/modules/wallpaper/qmldir
        qml/modules/settings/qmldir
        qml/modules/settings/pages/qmldir
)

target_link_libraries(nexus_qml PRIVATE
    nexus_backend
    Qt6::Quick
    Qt6::Qml
)

# ──────────────────────────────────────────────
# Main executable (QuickShell entry or standalone)
# ──────────────────────────────────────────────
qt_add_executable(nexus
    src/main.cpp
)

target_link_libraries(nexus PRIVATE
    nexus_backend
    nexus_qml
    Qt6::Quick
    Qt6::Qml
    Qt6::Gui
)

install(TARGETS nexus
    RUNTIME DESTINATION bin
)
install(DIRECTORY qml/
    DESTINATION share/nexus/qml
    FILES_MATCHING
        PATTERN "*.qml"
        PATTERN "qmldir"
)
