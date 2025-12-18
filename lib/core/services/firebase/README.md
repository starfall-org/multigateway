# Firebase AI Service

Service tích hợp Google Gemini AI thông qua Firebase AI SDK.

## Đặc điểm

- **Độc lập**: Không chia sẻ đối tượng nội bộ với các providers khác
- **DTO chung**: Sử dụng `AIModel` và `AIRequest`/`AIResponse` từ models chung
- **Firebase AI**: Sử dụng `firebase_ai` package (version 3.6.1)
- **List Models**: Gọi HTTP API của Gemini để lấy danh sách models

## Cách sử dụng

### 1. Khởi tạo

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'lib/core/services/firebase/ai.dart';
import 'lib/core/models/provider.dart';

// Khởi tạo Firebase
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// Tạo GoogleAI instance
final googleAI = GoogleAI(
  defaultModel: 'gemini-1.5-flash',
  useVertexAI: false, // true để dùng Vertex AI, false để dùng Google AI
  provider: Provider(
    name: 'Google',
    apiKey: 'YOUR_API_KEY',
    baseUrl: 'https://generativelanguage.googleapis.com',
  ),
);
```

### 2. Generate content

```dart
import 'lib/core/models/ai/ai_dto.dart';

final request = AIRequest(
  model: 'gemini-1.5-flash',
  messages: [
    AIMessage(
      role: 'user',
      content: [
        AIContent(type: AIContentType.text, text: 'Hello, Gemini!'),
      ],
    ),
  ],
  temperature: 0.7,
  maxTokens: 1024,
);

// Không streaming
final response = await googleAI.generate(request);
print(response.text);

// Với streaming
await for (final chunk in googleAI.generateStream(request)) {
  print(chunk.text);
}
```

### 3. Với images

```dart
import 'dart:convert';

final request = AIRequest(
  model: 'gemini-1.5-flash',
  messages: [
    AIMessage(
      role: 'user',
      content: [
        AIContent(type: AIContentType.text, text: 'Mô tả hình ảnh này'),
      ],
    ),
  ],
  images: [
    AIContent(
      type: AIContentType.image,
      dataBase64: base64ImageString,
      mimeType: 'image/jpeg',
    ),
  ],
);

final response = await googleAI.generate(request);
```

### 4. List models

```dart
final models = await googleAI.listModels();
for (final model in models) {
  print('${model.name}: ${model.contextWindow} tokens');
}
```

## Models mặc định

Nếu không có provider hoặc API call thất bại, service trả về danh sách models mặc định:

- `gemini-1.5-pro`: 2M tokens context, có tool calling, reasoning
- `gemini-1.5-flash`: 1M tokens context, có tool calling
- `gemini-2.0-flash-exp`: 1M tokens context, có tool calling, reasoning
- `gemini-pro-vision`: 32K tokens context, multimodal
- `text-embedding-004`: 2K tokens context, embedding model

## Lưu ý

1. **Firebase initialization**: Phải khởi tạo Firebase trước khi sử dụng GoogleAI
2. **API Key**: Cần API key từ Google AI Studio hoặc Vertex AI
3. **DTO models**: Sử dụng `AIRequest`, `AIResponse`, `AIModel` từ models chung
4. **Không chia sẻ**: Đối tượng `FirebaseAI` và `GenerativeModel` là private, không chia sẻ với providers khác