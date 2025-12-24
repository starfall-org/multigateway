## Mục tiêu (phục vụ debug)
- Tài liệu này dùng để hiểu nhanh các điểm nối quan trọng trong code khi debug (đường chạy, nơi dễ lỗi, chỗ nên đặt log/breakpoint).  
- Không mô tả UI/màu sắc; tập trung vào kiến trúc và luồng xử lý có ảnh hưởng trực tiếp tới bug.

## Đường chạy khởi động
- `lib/main.dart`
  - Thứ tự quan trọng: `WidgetsFlutterBinding.ensureInitialized()` → `Firebase.initializeApp(DefaultFirebaseOptions.currentPlatform)` → `AppServices.init()` → `initIcons()` → cấu hình `SystemChrome` → `runApp(const AIGatewayApp())`.
  - Nếu app crash ngay khi mở:
    - Đặt `try/catch` quanh `Firebase.initializeApp` và `AppServices.init()` để log `e` + `stackTrace`.  
    - Kiểm tra xem có chỗ nào dùng Firebase/Hive trước khi init xong hay không.
- `lib/app.dart` (`AIGatewayApp`)
  - Dùng `ValueListenableBuilder` nghe `AppearanceSp.themeNotifier`. Nếu UI không đổi theme hoặc crash trong đoạn build:
    - Log full object `settings` (themeMode, dynamicColor, superDarkMode, màu primary/secondary).  
    - Debug logic tạo `ColorScheme` (dynamic vs fromSeed).

## Service locator & lưu trữ (nếu bug liên quan dữ liệu)
- `lib/core/config/services.dart` (`AppServices`)
  - `init()` khởi tạo tuần tự:
    - `AppearanceSp`, `LanguageSp`, `PreferencesSp` (SharedPreferences).  
    - Các repository Hive: `ProviderRepository`, `DefaultOptionsRepository`, `ChatRepository`, `AIProfileRepository`, `MCPRepository`, `TTSRepository`.  
  - Bug thường gặp:
    - Lỗi mở box Hive (sai tên box, path, schema) → thêm log trong từng `*Repository.init()` với tên box và số record.  
    - Thay đổi model mà không migrate → crash khi parse; log raw record từ Hive trước khi map sang model.
- `lib/core/data/*`  
  - Mỗi file tương ứng một loại dữ liệu (chat, profile, provider, MCP, speech, cache dịch).  
  - Khi dữ liệu null/mất field: kiểm tra hàm từ JSON ↔ model và các chỗ `copyWith`.

## Tầng API (AI & MCP)
- `lib/api/ai/*`
  - Mỗi provider (OpenAI, Anthropic, Google AI, Ollama) có client riêng, dùng chung `http` và helper ở `utils.dart`.  
  - Khi debug call thất bại:
    - Log URL, method, header (mask API key), body request.  
    - Log `statusCode` + body response ở một chỗ trung tâm (trong `utils.dart`) để không phải chạm vào từng client.  
    - Nếu lỗi parse JSON: log body thô trước khi `jsonDecode`.
- `lib/api/mcp/mcp_client.dart`
  - Khi MCP không hoạt động / schema sai:
    - Log endpoints, payload gửi đi, payload nhận về.  
    - So sánh schema thực tế với định nghĩa type trong file này để tìm chỗ mismatch.

## Trạng thái UI & binding
- Các widget quan trọng:
  - `lib/features/home/ui/home_screen.dart` (`HomePage`) – shell điều hướng chính, có drawer.  
  - `lib/features/home/ui/chat_screen.dart` (`ChatPage`) – màn hình chat chính, lắng nghe `ChatViewModel`.  
  - `lib/features/settings/ui/settings_page.dart` – entry cho toàn bộ phần settings.
- Cập nhật UI:
  - `ChatPage` dùng `ListenableBuilder(listenable: _viewModel, ...)`.  
  - Nếu UI không update dù dữ liệu đổi: kiểm tra mọi method trong `ChatViewModel` đã gọi `notifyListeners()` sau khi mutate state hay chưa.

## Luồng khởi động
1) `main()` chạy chuỗi init như mô tả ở trên.  
2) `AIGatewayApp` build theme + route.  
3) `HomePage` build shell và điều hướng sang `ChatPage`/Settings/...  
4) `ChatPage` tạo `ChatViewModel` bằng `AppServices.instance` và gọi `_initializeViewModel()`:
   - `initChat()` → đọc session + messages từ `ChatRepository`.  
   - `loadSelectedProfile()` → đọc hồ sơ AI hiện tại từ `AIProfileRepository`.  
   - `refreshProviders()` → đọc config provider từ `ProviderRepository` + `DefaultOptionsRepository`.  
   Khi debug, nên log trước/sau từng lệnh `await` để biết chặn nào đang fail.

## Mô hình giao diện chat
- `ChatPage` dựa trên `ChatViewModel` (dùng `ChatRepository`, `AIProfileRepository`, `ProviderRepository`, `PreferencesSp`, `MCPRepository`, `TTSService`).  
- Để debug:
  - Đặt breakpoint ở constructor `ChatViewModel` và trong `initChat`/`sendMessage`/`retry` để xem state thay đổi ra sao.  
  - Khi message không hiển thị hoặc bị duplicate, kiểm tra list messages trong `ChatViewModel` trước và sau khi thao tác.  
  - Mọi chỗ dùng `context` trong async callback phải kiểm tra `mounted` (đã có trong `ChatPage` nhưng nên giữ nguyên nếu sửa).

## Chủ đề, ngôn ngữ, cấu hình
- Appearance: dynamic color nếu thiết bị hỗ trợ; nếu không, dùng `ColorScheme.fromSeed` với màu lấy từ `AppearanceSp`. Khi màu bị kỳ lạ/crash, log các field trong `AppearanceSetting`.  
- Ngôn ngữ/translate: `shared/translate/tl.dart` là entry; cache nằm ở `translation_cache_store.dart`. Nếu gặp key không dịch hoặc cache lỗi, log key + dữ liệu cache tương ứng.  
- Màn hình Settings chỉ là điểm vào để chỉnh các prefs; khi debug bug config, tập trung vào lớp prefs và repository hơn là UI.

