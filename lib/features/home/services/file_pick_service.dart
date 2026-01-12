import 'package:file_picker/file_picker.dart';

Future<void> filePickService(List<String> container) async {
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.any,
  );
  final paths = result?.paths.whereType<String>().toList() ?? const [];
  if (paths.isEmpty) return;

  for (final p in paths) {
    if (!container.contains(p)) {
      container.add(p);
    }
  }
}
