cmake_minimum_required(VERSION 3.16)

project(plasma-wallpaper-dynamicwallpaper)

find_package(ECM 5.90.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt6 REQUIRED COMPONENTS Core Quick)
find_package(KF6 REQUIRED COMPONENTS 
    Plasma 
    PlasmaQuick 
    Package 
    I18n
)

# Install the wallpaper plugin
plasma_install_package(. org.kde.plasma.dynamicwallpaper wallpapers wallpaper)

# Install configuration plugin files
install(FILES contents/ui/config.qml 
        DESTINATION ${KDE_INSTALL_DATADIR}/plasma/wallpapers/org.kde.plasma.dynamicwallpaper/contents/ui)

# Install metadata
install(FILES metadata.json 
        DESTINATION ${KDE_INSTALL_DATADIR}/plasma/wallpapers/org.kde.plasma.dynamicwallpaper)
