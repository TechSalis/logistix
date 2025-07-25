import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:logistix/features/auth/presentation/utils/auth_network_image.dart';


Future<void> cacheImageFromBytes(
  Uint8List bytes,
  AppNetworkImage imageKey,
) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();

  final completer = OneFrameImageStreamCompleter(
    Future.value(ImageInfo(image: frame.image)),
  );

  PaintingBinding.instance.imageCache.putIfAbsent(imageKey, () => completer);
}
