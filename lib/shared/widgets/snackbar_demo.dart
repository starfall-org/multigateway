import 'package:flutter/material.dart';
import 'app_snackbar.dart';

/// Demo page để minh họa cách sử dụng AppSnackBar
class SnackbarDemo extends StatelessWidget {
  const SnackbarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demo AppSnackBar')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demo các kiểu Snackbar:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Snackbar thành công
            ElevatedButton.icon(
              onPressed: () {
                context.showSuccessSnackBar(
                  'Lưu thành công! Dữ liệu đã được cập nhật.',
                  onUndo: () {
                    context.showInfoSnackBar('Đã hoàn tác thao tác');
                  },
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Hiển thị Snackbar Thành công'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Snackbar lỗi
            ElevatedButton.icon(
              onPressed: () {
                context.showErrorSnackBar(
                  'Đã xảy ra lỗi khi kết nối mạng. Vui lòng thử lại.',
                  onAction: () {
                    context.showInfoSnackBar('Đang thử lại...');
                  },
                  actionLabel: 'Thử lại',
                );
              },
              icon: const Icon(Icons.error),
              label: const Text('Hiển thị Snackbar Lỗi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Snackbar cảnh báo
            ElevatedButton.icon(
              onPressed: () {
                context.showWarningSnackBar(
                  'Cảnh báo: Dung lượng bộ nhớ sắp đầy.',
                  duration: const Duration(seconds: 6),
                );
              },
              icon: const Icon(Icons.warning),
              label: const Text('Hiển thị Snackbar Cảnh báo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 12),

            // Snackbar thông tin
            ElevatedButton.icon(
              onPressed: () {
                context.showInfoSnackBar(
                  'Thông tin: Bạn có 3 tin nhắn chưa đọc.',
                );
              },
              icon: const Icon(Icons.info),
              label: const Text('Hiển thị Snackbar Thông tin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              'Cách sử dụng trong code:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '''// Sử dụng extension của BuildContext
context.showSuccessSnackBar('Thành công!');
context.showErrorSnackBar('Có lỗi xảy ra');
context.showWarningSnackBar('Cảnh báo');
context.showInfoSnackBar('Thông tin');

// Hoặc sử dụng static method
AppSnackBar.showSuccess(context, 'Thành công!');
AppSnackBar.showError(context, 'Lỗi');''',
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
