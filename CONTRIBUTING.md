# Contributing to Metalore

Thank you for your interest in contributing to Metalore! This guide will help you understand how to contribute to different parts of the project.

## Project Overview

Metalore is a Flutter-based LLM client application that provides a unified interface for interacting with multiple LLM providers. The project uses a feature-based modular architecture with local packages for LLM and MCP implementations.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Contributing to Different Parts](#contributing-to-different-parts)
  - [Main App (lib/)](#main-app-lib)
  - [LLM Providers (llm/)](#llm-providers-llm)
  - [MCP Implementation (mcp/)](#mcp-implementation-mcp)
  - [UI and Features](#ui-and-features)
  - [Platform-Specific Code](#platform-specific-code)
- [Code Conventions](#code-conventions)
- [Testing](#testing)
- [Documentation](#documentation)

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.10.0)
- Dart SDK (>= 3.10.0)
- Android Studio (for Android development)
- Xcode (for iOS/macOS development, macOS only)
- Git

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/starfall-org/metalore.git
   cd metalore
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Install dependencies for local packages:
   ```bash
   cd llm && flutter pub get && cd ..
   cd mcp && flutter pub get && cd ..
   ```

4. Run code generation (for Hive adapters, JSON serialization):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
metalore/
├── lib/                    # Main application code
│   ├── app/               # App-level widgets and configuration
│   ├── core/              # Core models, utilities, app routes
│   ├── features/          # Feature modules (ai, home, settings)
│   └── shared/            # Shared widgets and utilities
├── llm/                   # LLM provider implementations
│   ├── lib/
│   │   ├── models/        # Request/response models
│   │   └── provider/      # Provider implementations
│   └── PROVIDER_API_PATTERN.md
├── mcp/                   # MCP (Model Context Protocol) client
│   └── lib/
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── web/                   # Web-specific code
├── linux/                 # Linux-specific code
├── macos/                 # macOS-specific code
├── windows/               # Windows-specific code
└── test/                  # Test files
```

## Contributing to Different Parts

### Main App (lib/)

The main app follows a feature-based modular architecture. Each feature is self-contained with its own controllers, services, UI components, and utilities.

**When to contribute:**
- Adding new features
- Modifying existing UI
- Changing app-level configuration
- Updating routing or navigation

**Key conventions:**
- Each feature in `lib/features/` has subdirectories: `controllers/`, `services/`, `ui/`, `utils/`
- Controllers extend `ChangeNotifier` and call `notifyListeners()` after state changes
- Use UUID for IDs: `const Uuid().v4()`
- Use `tl('key')` function for translations
- Store data using Hive for models, SharedPreferences for settings

**Example workflow:**
1. Create new feature in `lib/features/your_feature/`
2. Add controller, services, UI components as needed
3. Register routes in `core/app_routes.dart` and `routes.dart`
4. Test on multiple platforms

### LLM Providers (llm/)

The `llm` package contains implementations for various LLM providers (OpenAI, Anthropic, GoogleAI, Ollama, etc.).

**When to contribute:**
- Adding support for a new LLM provider
- Updating existing provider implementations
- Adding new endpoints to existing providers
- Fixing bugs in provider implementations

**Key conventions:**
- Follow the Provider API Pattern (see `llm/PROVIDER_API_PATTERN.md`)
- Each provider should have separate methods for each endpoint
- Use type-safe request/response models
- All models should use `@JsonSerializable` for serialization
- Provider classes should follow the naming pattern: `{ProviderName}Provider`

**Example workflow:**
1. Create request/response models in `llm/lib/models/api/{provider}/`
2. Run code generation: `flutter pub run build_runner build`
3. Implement provider in `llm/lib/provider/{provider}/{provider}.dart`
4. Add provider enum to `core/models/ai/provider.dart` in main app
5. Update tests if applicable

### MCP Implementation (mcp/)

The `mcp` package implements the Model Context Protocol client for Metalore.

**When to contribute:**
- Implementing new MCP features
- Adding support for new MCP server types
- Improving MCP connection handling
- Fixing MCP-related bugs

**Key conventions:**
- Use `http` package for network requests
- Implement proper error handling
- Follow existing patterns in the package
- Ensure type safety with proper models

### UI and Features

UI components and features are organized in the `lib/features/` directory.

**When to contribute:**
- Creating new screens or widgets
- Improving existing UI
- Adding new settings or preferences
- Implementing user interactions

**Key conventions:**
- Use Material Design 3 components
- Support dynamic colors (via `dynamic_color` package)
- Ensure responsive design for different screen sizes
- Follow Flutter best practices for widget composition
- Use proper state management (ChangeNotifier controllers)

**Example workflow:**
1. Create UI in `lib/features/your_feature/ui/`
2. Create controller in `lib/features/your_feature/controllers/`
3. Add routes to `core/app_routes.dart`
4. Test on different screen sizes

### Platform-Specific Code

Platform-specific code is in directories like `android/`, `ios/`, `web/`, `linux/`, `macos/`, and `windows/`.

**When to contribute:**
- Adding platform-specific features
- Fixing platform-specific bugs
- Improving platform integration
- Adding native functionality

**Key conventions:**
- Keep platform-specific code minimal
- Use platform channels only when necessary
- Test on target platform before submitting
- Document any platform-specific limitations

**Example workflow:**
1. Identify if feature needs native code
2. Implement in appropriate platform directory
3. Add platform channel if needed
4. Test on target platform

## Code Conventions

### Dart/Flutter Style

- Follow official Dart style guide
- Use `flutter_lints` for linting
- Keep functions short and focused
- Use meaningful variable and function names
- Add type annotations for public APIs

### State Management

- Controllers extend `ChangeNotifier`
- Call `notifyListeners()` after state changes
- Use `Future<void>` for async operations
- Handle errors with try-catch and show user feedback via `ScaffoldMessenger`

### Data Persistence

- Use `@HiveType` for Hive models
- Extend `HiveBaseStorage` for storage classes
- Register Hive types in `main.dart` TypeAdapters list
- Run `flutter pub run build_runner build` after adding new Hive types

### Testing

- Write unit tests for business logic
- Write widget tests for UI components
- Use `flutter_test` framework
- Maintain good test coverage

## Documentation

### Code Comments

- Add comments for complex logic
- Document public APIs
- Explain non-obvious implementations

### README Updates

When adding significant features:
- Update feature list in `README.md` if applicable
- Add documentation for new features
- Update version numbers if necessary

### Feature Documentation

Each feature should have a `feature.md` file in its directory documenting:
- Purpose of the feature
- Key components
- How to extend or modify
- Related features or dependencies

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run tests for specific package
cd llm && flutter test
cd mcp && flutter test
```

### Testing Platforms

Test your changes on:
- Web (easiest for quick iteration)
- Android (or iOS) for mobile-specific features
- Desktop platforms if applicable

## Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Run tests and linting
5. Ensure code follows conventions
6. Update documentation if needed
7. Submit a pull request with:
   - Clear description of changes
   - Related issues
   - Screenshots for UI changes
   - Testing notes

## Getting Help

- Check existing issues for similar problems
- Review `llm/PROVIDER_API_PATTERN.md` for provider patterns
- Refer to `.github/copilot-instructions.md` for architectural guidance
- Open an issue for bugs or questions

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (Starfall License).
