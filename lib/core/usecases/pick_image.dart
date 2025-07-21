import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PickImageUsecase {
  final ImagePicker _picker;

  PickImageUsecase({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  Future<File?> call() async {
    final result = await _picker.pickImage(
      requestFullMetadata: false,
      source: ImageSource.gallery,
      imageQuality: 70,
      maxHeight: 720,
      maxWidth: 720,
    );
    if (result != null) return File(result.path);
    return null;
  }
}
