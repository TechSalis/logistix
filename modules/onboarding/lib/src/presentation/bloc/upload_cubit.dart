import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onboarding/src/presentation/bloc/upload_state.dart';
import 'package:shared/shared.dart';

class UploadCubit extends Cubit<UploadState> {
  UploadCubit(this._resolveRepository) : super(const UploadState.initial());

  final UploadRepository _resolveRepository;

  Future<void> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result == null || result.files.single.path == null) return;

    final file = File(result.files.single.path!);
    final fileName = result.files.single.name;

    emit(const UploadState.loading());

    // 1. Get Presigned URL
    final presignedResult = await _resolveRepository.getPresignedUrl(fileName);

    await presignedResult.when(
      data: (data) async {
        // 2. Upload to S3/R2
        final uploadResult = await _resolveRepository.uploadFile(
          file,
          data.url,
        );

        uploadResult.when(
          data: (_) => emit(UploadState.success(key: data.key)),
          error: (err) => emit(UploadState.error(message: err.message)),
        );
      },
      error: (err) async => emit(UploadState.error(message: err.message)),
    );
  }

  void reset() => emit(const UploadState.initial());
}
