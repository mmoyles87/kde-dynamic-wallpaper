#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="org.kde.plasma.dynamicwallpaper"
USER_INSTALL_DIR="$HOME/.local/share/plasma/wallpapers/$PLUGIN_ID"

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
    echo "  test        Install and open wallpaper settings"
    echo "  test-package Test production package in user directory"
    echo "  logs        Show wallpaper logs in real-time"
    echo "  restart     Restart Plasma shell"
    echo "  clean       Clean user installations"
    echo "  uninstall   Remove user installation"
    echo "  package     Create distribution package"
    echo "  release     Create GitHub release with current version"
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
    echo "Cleaning installations..."
    
    rm -rf "$USER_INSTALL_DIR"
    
    echo "Clean complete"
}

uninstall_all() {
    echo "Removing all installations..."
    
    rm -rf "$USER_INSTALL_DIR"
    
    echo "Uninstall complete"
}

test_package() {
    echo "Testing production package..."
    
    # Check if package exists
    PACKAGE_FILE=$(ls kde6-dynamic-wallpaper-*.tar.xz 2>/dev/null | head -1)
    if [ -z "$PACKAGE_FILE" ]; then
        echo "Error: No package file found. Run './dev-helper.sh package' first."
        exit 1
    fi
    
    echo "Found package: $PACKAGE_FILE"
    
    # Remove existing installation
    rm -rf "$USER_INSTALL_DIR"
    
    # Create temporary directory and extract package
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    tar -xf "$SCRIPT_DIR/$PACKAGE_FILE"
    
    # Install from extracted package
    mkdir -p "$USER_INSTALL_DIR"
    cp -r * "$USER_INSTALL_DIR/"
    
    # Cleanup
    cd "$SCRIPT_DIR"
    rm -rf "$TEMP_DIR"
    
    echo "Production package installed to: $USER_INSTALL_DIR"
    echo ""
    echo "To use:"
    echo "1. Open System Settings > Appearance > Wallpaper"
    echo "2. Select 'Dynamic Wallpaper' from dropdown"
    echo "3. Configure and apply"
    echo ""
    echo "Note: This tests the exact package that would be distributed to users."
}

main() {
    cd "$SCRIPT_DIR"
    check_project_root
    
    case "${1:-help}" in
        install)
            install_user
            ;;
        test)
            test_wallpaper
            ;;
        test-package)
            test_package
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
        release)
            ./release.sh
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
