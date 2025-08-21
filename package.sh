#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ID="org.kde.plasma.dynamicwallpaper"
VERSION=$(grep '"Version"' metadata.json | sed 's/.*"Version": "\([^"]*\)".*/\1/')
PACKAGE_NAME="kde6-dynamic-wallpaper-${VERSION}"
TEMP_DIR="/tmp/${PACKAGE_NAME}"

check_project_root() {
    if [ ! -f "metadata.json" ]; then
        echo "Error: metadata.json not found. Run this script from the project root directory."
        exit 1
    fi
}

create_package() {
    echo "Creating KDE Store package for version $VERSION..."
    
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    echo "Copying files to temporary directory..."
    cp -r contents/ "$TEMP_DIR/"
    cp metadata.json "$TEMP_DIR/"
    cp -r images/ "$TEMP_DIR/"
    cp README.md "$TEMP_DIR/"
    
    # Include any screenshot files
    if ls Screenshot_*.png >/dev/null 2>&1; then
        cp Screenshot_*.png "$TEMP_DIR/"
    fi
    
    cd "$TEMP_DIR"
    echo "Creating tar.xz archive..."
    tar -cJf "${PACKAGE_NAME}.tar.xz" *
    
    mv "${PACKAGE_NAME}.tar.xz" "$SCRIPT_DIR/"
    cd "$SCRIPT_DIR"
    rm -rf "$TEMP_DIR"
    
    echo ""
    echo "Package created: ${PACKAGE_NAME}.tar.xz"
    echo "File size: $(du -h "${SCRIPT_DIR}/${PACKAGE_NAME}.tar.xz" | cut -f1)"
    echo ""
    echo "Ready for upload to https://store.kde.org/"
    echo ""
    echo "Upload instructions:"
    echo "1. Go to https://store.kde.org/"
    echo "2. Login and navigate to 'Add Product'"
    echo "3. Select category: Plasma Addons > Wallpapers"
    echo "4. Upload the ${PACKAGE_NAME}.tar.xz file"
    echo "5. Fill in description and screenshots"
}

main() {
    cd "$SCRIPT_DIR"
    check_project_root
    create_package
}

main "$@"
