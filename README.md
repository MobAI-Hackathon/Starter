# Drawzy Frontend

A Flutter-based mobile application frontend providing a modern and responsive user interface.

## Table of Contents
1. [Overview](#overview)
2. [Project Structure](#project-structure)
3. [Installation & Setup](#installation--setup)
4. [Usage](#usage)
5. [Assets](#assets)
6. [Platform Support](#platform-support)
7. [Contributing](#contributing)

## Overview

This Flutter application serves as the frontend interface, supporting multiple platforms including iOS, Android, web, and desktop environments.

## Project Structure

```
frontend/
├── lib/             # Main Dart source code
├── assets/          # Static assets
├── asset/
│   └── images/      # Image resources
├── android/         # Android-specific configurations
├── ios/             # iOS-specific configurations
├── web/             # Web platform files
├── windows/         # Windows desktop configuration
├── linux/           # Linux desktop configuration
├── macos/           # macOS desktop configuration
└── pubspec.yaml     # Project dependencies and settings
```

## Installation & Setup

1. **Prerequisites**
   ```bash
   flutter --version   # Ensure Flutter is installed
   ```

2. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd frontend
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the Application**
   ```bash
   flutter run
   ```

## Usage

1. **Development Mode**
   ```bash
   flutter run
   ```

2. **Build Release Version**
   ```bash
   flutter build <platform>
   ```
   Replace `<platform>` with:
   - `apk` for Android
   - `ios` for iOS
   - `web` for web
   - `windows` for Windows
   - `macos` for macOS
   - `linux` for Linux

## Assets

- Images and static resources are stored in the `asset/images/` directory
- Additional assets can be configured in `pubspec.yaml`

## Platform Support

This application is configured to run on:
- Android
- iOS
- Web
- Windows
- Linux
- macOS

Each platform has its specific configuration in its respective directory.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

**Note:** Update the dependencies regularly and ensure compatibility with the latest Flutter version.

