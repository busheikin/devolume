# DeVolume

A macOS application to manage processes using external volumes. DeVolume helps you identify and terminate processes that are preventing external volumes from being ejected.

## Download and Install

1. Go to the [Releases](https://github.com/antler-hat/devolume/releases) page
2. Download the latest `DeVolume.zip`
3. Unzip the file
4. Drag `DeVolume.app` to your Applications folder
5. When you first run the app, right-click (or Control-click) on the app and select "Open" to bypass macOS security

## Features

- Lists all external volumes connected to your Mac
- Shows processes using a selected volume
- Allows you to terminate processes preventing volume ejection
- Modern macOS native interface

## Building from Source

If you prefer to build the application yourself:

1. Clone the repository:
   ```bash
   git clone https://github.com/antler-hat/devolume.git
   cd devolume
   ```

2. Run the build script:
   ```bash
   ./build.sh
   ```

3. The application will be installed in your Applications folder

## Requirements

- macOS 10.13 or later
- Administrator privileges (for terminating processes)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request 