#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION=$(grep '"Version"' metadata.json | sed 's/.*"Version": "\([^"]*\)".*/\1/')
PACKAGE_NAME="kde6-dynamic-wallpaper-${VERSION}"
PACKAGE_FILE="${PACKAGE_NAME}.tar.xz"

check_requirements() {
    if ! command -v gh &> /dev/null; then
        echo "Error: GitHub CLI (gh) is not installed."
        echo "Install it with: sudo apt install gh"
        echo "Then authenticate with: gh auth login"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        echo "Error: Not authenticated with GitHub CLI."
        echo "Run: gh auth login"
        exit 1
    fi
    
    if [ ! -f "metadata.json" ]; then
        echo "Error: metadata.json not found. Run this script from the project root directory."
        exit 1
    fi
}

check_git_status() {
    if [ -n "$(git status --porcelain)" ]; then
        echo "Warning: You have uncommitted changes."
        echo "Git status:"
        git status --short
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Aborted."
            exit 1
        fi
    fi
}

create_package() {
    echo "Creating package for version $VERSION..."
    ./package.sh
    
    if [ ! -f "$PACKAGE_FILE" ]; then
        echo "Error: Package file $PACKAGE_FILE not found!"
        exit 1
    fi
    
    echo "Package created: $PACKAGE_FILE ($(du -h "$PACKAGE_FILE" | cut -f1))"
}

create_release() {
    local tag="v$VERSION"
    local title="KDE6 Dynamic Wallpaper v$VERSION"
    
    echo "Creating GitHub release: $tag"
    
    # Check if tag already exists
    if git tag -l | grep -q "^$tag$"; then
        echo "Warning: Tag $tag already exists!"
        read -p "Delete existing tag and continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git tag -d "$tag"
            git push origin ":refs/tags/$tag" 2>/dev/null || true
        else
            echo "Aborted."
            exit 1
        fi
    fi
    
    # Create release notes
    local release_notes="## KDE6 Dynamic Wallpaper v$VERSION

### Features
- Automatic wallpaper switching based on astronomical calculations
- Support for dawn, morning, day, evening, dusk, and night images
- IP-based geolocation and timezone-based location detection
- Manual coordinate configuration
- Multiple fill mode options
- Real-time debugging and logging

### Installation
1. Download the \`$PACKAGE_FILE\` file below
2. Open KDE System Settings > Appearance > Wallpaper
3. Click \"Get New Wallpapers\" and install the downloaded file
4. Select \"Dynamic Wallpaper\" from the wallpaper type dropdown

### Package Contents
- Ready-to-install KDE wallpaper plugin
- Compatible with KDE Plasma 6
- No compilation required

### Links
- [KDE Store Page](https://store.kde.org/)
- [GitHub Repository](https://github.com/mmoyles87/kde-dynamic-wallpaper)
- [Bug Reports & Issues](https://github.com/mmoyles87/kde-dynamic-wallpaper/issues)"

    # Create the release
    gh release create "$tag" "$PACKAGE_FILE" \
        --title "$title" \
        --notes "$release_notes" \
        --draft=false \
        --prerelease=false
    
    echo ""
    echo "✅ Release created successfully!"
    echo "🔗 View release: https://github.com/mmoyles87/kde-dynamic-wallpaper/releases/tag/$tag"
    echo "📦 Package uploaded: $PACKAGE_FILE"
    echo ""
    echo "Next steps:"
    echo "1. Update KDE Store with new version"
    echo "2. Share the release with users"
    echo "3. Consider updating documentation if needed"
}

show_usage() {
    echo "GitHub Release Creator for KDE6 Dynamic Wallpaper"
    echo ""
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without creating release"
    echo "  --help       Show this help message"
    echo ""
    echo "This script will:"
    echo "1. Check git status and requirements"
    echo "2. Create package using package.sh"
    echo "3. Create GitHub release with tag v$VERSION"
    echo "4. Upload the package file as release asset"
}

main() {
    cd "$SCRIPT_DIR"
    
    case "${1:-}" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --dry-run)
            echo "DRY RUN MODE - No changes will be made"
            echo ""
            echo "Would create release:"
            echo "  Version: $VERSION"
            echo "  Tag: v$VERSION"
            echo "  Package: $PACKAGE_FILE"
            echo ""
            echo "Requirements check:"
            check_requirements
            echo "✅ All requirements met"
            exit 0
            ;;
        "")
            # Normal execution
            echo "🚀 Creating GitHub release for KDE6 Dynamic Wallpaper v$VERSION"
            echo ""
            
            check_requirements
            check_git_status
            create_package
            create_release
            ;;
        *)
            echo "Error: Unknown option '$1'"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
