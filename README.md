# 🛑 PROJECT DISCONTINUED INDEFINITELY

> **Warning: This project is no longer maintained and has been suspended indefinitely.**

---

# MultiGateway

MultiGateway is a versatile LLM client application that provides a unified interface for interacting with multiple LLM providers, offering seamless integration across various AI services.

## Features

- 🤖 Multi-provider LLM support (OpenAI, Anthropic, Google, and more)
- 💬 Intuitive chat interface with rich messaging capabilities
- 🔧 Flexible configuration and customization options
- 📱 Cross-platform compatibility
- 🎨 Beautiful UI with multiple themes
- 🔧 MCP (Model Context Protocol) server integration
- 🎯 Profile-based conversations
- 🎤 Speech-to-text and text-to-speech support

## Download & Installation

### Android (Pre-built Available)
Ready to use! Download the latest APK from our [Releases](../../releases) page.

### Other Platforms (Build Required)
Currently, only Android builds are provided pre-compiled. For iOS, Web, Windows, macOS, or Linux platforms, you'll need to build from source code following the instructions below.

## Platform Support

- [x] Android *(pre-built available)*
- [x] iOS *(build from source)*
- [x] Web *(build from source)*
- [x] Windows *(build from source)*
- [x] macOS *(build from source)*
- [x] Linux *(build from source)*

## Building from Source

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK
- Platform-specific requirements:
  - Android Studio (for Android)
  - Xcode (for iOS/macOS)
  - Chrome (for Web)
  - Visual Studio (for Windows)

### Build Instructions
```bash
# Clone the repository
git clone <repository-url>
cd multigateway

# Install dependencies
flutter pub get

# Build for your target platform
flutter build apk                # Android APK
flutter build appbundle         # Android App Bundle
flutter build ios               # iOS
flutter build web               # Web
flutter build windows           # Windows
flutter build macos             # macOS
flutter build linux             # Linux
```

# Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on how to contribute to the project.

# license

[![License: SPLicense](https://img.shields.io/badge/Starfall-LICENSE-blue.svg)](LICENSE)
