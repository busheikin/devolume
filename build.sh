#!/bin/bash

# Exit on error
set -e

# Create build directory
mkdir -p build

# Compile the application
echo "Compiling DeVolume..."
swiftc -sdk $(xcrun --show-sdk-path --sdk macosx) \
    -target arm64-apple-macosx10.13 \
    -o build/DeVolume \
    DeVolume/Sources/Models/*.swift \
    DeVolume/Sources/ViewControllers/*.swift \
    DeVolume/Sources/AppDelegate.swift \
    DeVolume/Sources/main.swift \
    -import-objc-header DeVolume/Sources/DeVolume-Bridging-Header.h

# Create application bundle structure
echo "Creating application bundle..."
mkdir -p build/DeVolume.app/Contents/MacOS
mkdir -p build/DeVolume.app/Contents/Resources

# Copy executable
cp build/DeVolume build/DeVolume.app/Contents/MacOS/

# Copy Info.plist
cp DeVolume/Info.plist build/DeVolume.app/Contents/

# Copy app icon if it exists
if [ -f "DeVolume/Resources/AppIcon.icns" ]; then
    echo "Adding app icon..."
    cp DeVolume/Resources/AppIcon.icns build/DeVolume.app/Contents/Resources/
fi

# Install to Applications folder
echo "Installing to Applications folder..."
mkdir -p ~/Applications
rm -rf ~/Applications/DeVolume.app
cp -R build/DeVolume.app ~/Applications/

echo "Build complete! DeVolume.app has been installed to ~/Applications/" 