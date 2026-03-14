import 'package:freezed_annotation/freezed_annotation.dart';

part 'presigned_url.freezed.dart';
part 'presigned_url.g.dart';

@freezed
class PresignedUrl with _$PresignedUrl {
  const factory PresignedUrl({required String url, required String key}) =
      _PresignedUrl;

  factory PresignedUrl.fromJson(Map<String, dynamic> json) =>
      _$PresignedUrlFromJson(json);
}
