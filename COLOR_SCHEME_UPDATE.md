# Cập nhật Color Scheme Selector

## Tổng quan
Đã cập nhật phần chọn màu sắc trong cài đặt giao diện với các tính năng sau:

### 1. Color Scheme Presets
- Thêm 8 bộ màu preset có sẵn:
  - Blue (Xanh dương)
  - Purple (Tím)
  - Green (Xanh lá)
  - Orange (Cam)
  - Pink (Hồng)
  - Red (Đỏ)
  - Teal (Xanh ngọc)
  - Indigo (Chàm)
  - Custom (Tùy chỉnh)

### 2. Hiển thị có điều kiện
- Color Scheme Selector chỉ hiển thị khi **Dynamic Color bị tắt**
- Khi Dynamic Color được bật, ứng dụng sẽ sử dụng màu từ wallpaper

### 3. Chế độ Custom
- Khi chọn preset "Custom", người dùng mới thấy các tùy chọn chỉnh màu chi tiết:
  - Primary Color (Màu chính)
  - Secondary Color (Màu phụ)
  - Background Color (Màu nền)
  - Surface Color (Màu bề mặt)

### 4. Giao diện
- Các preset được hiển thị dưới dạng chip với:
  - Tên màu
  - Vòng tròn màu preview (trừ Custom)
  - Border highlight khi được chọn
  - Background màu nhạt khi được chọn

## Files đã thay đổi

### 1. `lib/app/models/appearance_setting.dart`
- Thêm enum `ColorSchemePreset` với 9 giá trị
- Thêm field `colorSchemePreset` vào `AppearanceSetting`
- Thêm factory method `ColorSettings.fromPreset()` để tạo màu từ preset

### 2. `lib/features/settings/presentation/controllers/appearance_controller.dart`
- Thêm method `updateColorSchemePreset()` để cập nhật preset đã chọn
- Tự động cập nhật màu sắc khi chọn preset (trừ Custom)

### 3. `lib/features/settings/presentation/widgets/appearance/color_scheme_selector.dart` (MỚI)
- Widget mới để hiển thị color scheme selector
- Chỉ hiển thị khi `dynamicColor == false`
- Hiển thị các preset dưới dạng chip
- Hiển thị custom color pickers khi chọn Custom preset

### 4. `lib/features/settings/presentation/appearance_page.dart`
- Import và thêm `ColorSchemeSelector` vào layout
- Đặt sau `AdditionalSettingsSection`

### 5. `lib/app/models/appearance_setting.g.dart`
- File generated tự động cập nhật với enum mới

## Cách sử dụng

1. Vào **Settings** → **Appearance**
2. Tắt **Dynamic Colors** (nếu đang bật)
3. Phần **Color Scheme** sẽ xuất hiện
4. Chọn một trong các preset có sẵn hoặc chọn **Custom**
5. Nếu chọn Custom, các tùy chọn chỉnh màu chi tiết sẽ hiển thị bên dưới

## Lưu ý kỹ thuật

- Tất cả text đều sử dụng `tl()` function để hỗ trợ đa ngôn ngữ tự động
- Màu sắc được lưu dưới dạng ARGB32 integer
- Preset colors sử dụng Material Design colors
- State được quản lý qua `AppearanceController` và tự động persist
