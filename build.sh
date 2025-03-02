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
    DeVolume/Sources/DeVolume.swift

# Create application bundle structure
echo "Creating application bundle..."
mkdir -p build/DeVolume.app/Contents/MacOS
mkdir -p build/DeVolume.app/Contents/Resources

# Copy executable
cp build/DeVolume build/DeVolume.app/Contents/MacOS/

# Copy Info.plist
cp DeVolume/Info.plist build/DeVolume.app/Contents/

# Install to Applications folder
echo "Installing to Applications folder..."
rm -rf ~/Applications/DeVolume.app
cp -R build/DeVolume.app ~/Applications/

echo "Build complete! DeVolume.app has been installed to ~/Applications/" 