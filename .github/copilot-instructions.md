# AI Gateway Copilot Instructions

This project is a Flutter application providing a unified interface for multiple LLM providers.

## Architecture

- **Feature-based modular architecture**: Each feature (home, ai, settings) lives in `lib/features/`. Each feature has controllers/, services/, ui/, utils/ subdirectories.

- **State Management**: MVC-style with controllers extending `ChangeNotifier`. Main ChatController orchestrates sub-controllers (MessageController, SessionController, etc.) and calls `notifyListeners()` for UI updates.

- **Data Storage**:

  - Hive for models (@HiveType classes in core/models), persisted conversations/messages
  - SharedPreferences for app settings (appearance, preferences)
  - Firebase optional for remote services

- **API Layer**: HTTP-based clients extending `AIBaseApi` in `lib/api/` for each provider (Anthropic, OpenAI, GoogleAI, etc.). Request/response models in `core/models/ai/`.

- **Routing**: Named routes in `core/app_routes.dart` with `Navigator.of(context).pushNamed(AppRoutes.chat)`.

- **Services**: Dependency injection via singleton services in `core/config/services.dart` initialized in `main.dart`.

## Key Conventions

- Controllers extend `ChangeNotifier`, call `notifyListeners()` after state changes

- Model classes use `@HiveType` for persistence, extend `HiveBaseStorage` for storage

- Async operations with `Future<void>`, error handling with `try-catch` showing `ScaffoldMessenger.of(context).showSnackBar()`

- Use UUID for IDs (`const Uuid().v4()`), translation with `tl('key')` function

- Attachments stored as `List<String> filePaths`, images/text support in models

## Development Workflow

- Add AI provider: Create enum entry in core/models/ai/provider.dart, implement client in api/ai/, add routes if needed

- Register Hive types: Add @HiveType classes to main.dart TypeAdapters list, run `flutter pub run build_runner build`

- Add screen: Create in features//ui/, add route to app_routes.dart and routes.dart

- Theming: Dynamic color support in app.dart, settings in shared/prefs/appearance.dart

## Code Examples

```dart
// Controller pattern
class ExampleController extends ChangeNotifier {
  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> fetchData() async {
    setLoading(true);
    try {
      // API call
      await Future.delayed(Duration(seconds: 1));
      setLoading(false);
    } catch (e) {
      setLoading(false);
      // Show error via snackbar
    }
  }
}

// Message handling
final newMessage = ChatMessage(
  id: const Uuid().v4(),
  role: ChatRole.user,
  content: text,
  timestamp: DateTime.now(),
  attachments: attachmentPaths,
);

// Navigation
Navigator.of(context).pushNamed(AppRoutes.settings);
```

## Debugging

- Inspect ChangeNotifier state via breakpoints in controllers

- Hive devtools for persisted data, check boxes: ChatStore, AIProfileStore, etc.

- File paths for attachments/images in debug logs

- Firebase debugging if enabled for crash/error tracking
