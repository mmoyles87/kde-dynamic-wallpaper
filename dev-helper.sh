#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="org.kde.plasma.dynamicwallpaper"
USER_INSTALL_DIR="$HOME/.local/share/plasma/wallpapers/$PLUGIN_ID"
SYSTEM_INSTALL_DIR="/usr/share/plasma/wallpapers/$PLUGIN_ID"

check_project_root() {
    if [ ! -f "metadata.json" ]; then
        echo "Error: metadata.json not found. Run this script from the project root directory."
        exit 1
    fi
}

show_usage() {
    echo "KDE6 Dynamic Wallpaper Development Helper"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  install     Install to user directory for development"
    echo "  system      Install system-wide using CMake"
    echo "  test        Install and open wallpaper settings"
    echo "  logs        Show wallpaper logs in real-time"
    echo "  restart     Restart Plasma shell"
    echo "  clean       Clean build directories and installations"
    echo "  uninstall   Remove all installations"
    echo "  package     Create distribution package"
    echo "  help        Show this help message"
}

install_user() {
    echo "Installing KDE6 Dynamic Wallpaper to user directory..."
    
    rm -rf "$USER_INSTALL_DIR"
    mkdir -p "$USER_INSTALL_DIR"
    
    cp -r contents/ "$USER_INSTALL_DIR/"
    cp metadata.json "$USER_INSTALL_DIR/"
    cp -r images/ "$USER_INSTALL_DIR/"
    
    echo "Development installation complete: $USER_INSTALL_DIR"
    echo ""
    echo "To use:"
    echo "1. Open System Settings > Appearance > Wallpaper"
    echo "2. Select 'Dynamic Wallpaper' from dropdown"
    echo "3. Configure and apply"
}

install_system() {
    echo "Installing KDE6 Dynamic Wallpaper system-wide..."
    
    mkdir -p build
    cd build
    
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    make
    sudo make install
    
    cd ..
    echo "System installation complete!"
}

test_wallpaper() {
    echo "Testing KDE6 Dynamic Wallpaper..."
    install_user
    echo ""
    echo "Opening wallpaper settings..."
    systemsettings kcm_wallpaper &
}

show_logs() {
    echo "Showing Dynamic Wallpaper logs (Ctrl+C to exit)..."
    journalctl --user -f | grep --line-buffered "Dynamic Wallpaper\|qml:"
}

restart_plasma() {
    echo "Restarting Plasma shell..."
    kquitapp6 plasmashell && plasmashell &
    echo "Plasma restarted"
}

clean_all() {
    echo "Cleaning build directories and installations..."
    
    rm -rf build/
    rm -rf "$USER_INSTALL_DIR"
    
    if [ -d "$SYSTEM_INSTALL_DIR" ]; then
        echo "Removing system installation (requires sudo)..."
        sudo rm -rf "$SYSTEM_INSTALL_DIR"
    fi
    
    echo "Clean complete"
}

uninstall_all() {
    echo "Removing all installations..."
    
    rm -rf "$USER_INSTALL_DIR"
    
    if [ -d "$SYSTEM_INSTALL_DIR" ]; then
        echo "Removing system installation (requires sudo)..."
        sudo rm -rf "$SYSTEM_INSTALL_DIR"
    fi
    
    echo "Uninstall complete"
}

main() {
    cd "$SCRIPT_DIR"
    check_project_root
    
    case "${1:-help}" in
        install)
            install_user
            ;;
        system)
            install_system
            ;;
        test)
            test_wallpaper
            ;;
        logs)
            show_logs
            ;;
        restart)
            restart_plasma
            ;;
        clean)
            clean_all
            ;;
        uninstall)
            uninstall_all
            ;;
        package)
            ./package.sh
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            echo "Error: Unknown command '$1'"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
