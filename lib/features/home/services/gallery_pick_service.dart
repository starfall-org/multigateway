import 'package:image_picker/image_picker.dart';

Future<void> galleryPickService(List<String> container) async {
  final result = await ImagePicker().pickMultiImage();
  final paths = result.map((e) => e.path).toList();
  if (paths.isEmpty) return;

  for (final p in paths) {
    if (!container.contains(p)) {
      container.add(p);
    }
  }
}
