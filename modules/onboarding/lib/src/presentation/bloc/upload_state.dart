import 'package:freezed_annotation/freezed_annotation.dart';

part 'upload_state.freezed.dart';

@freezed
class UploadState with _$UploadState {
  const factory UploadState.initial() = Initial;
  const factory UploadState.loading() = Loading;
  const factory UploadState.success({required String key}) = Success;
  const factory UploadState.error({String? message}) = Error;
}
