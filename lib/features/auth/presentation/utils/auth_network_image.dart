import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';

class AppNetworkImage extends ImageProvider<AppNetworkImage> {
  final String url;
  const AppNetworkImage(this.url);

  @override
  ImageStreamCompleter loadImage(
    AppNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    final image = NetworkImage(
      url,
      headers: {
        'Authorization':
            'Bearer ${AuthLocalStore.instance.getSession()?.token}',
      },
    );
    return image.loadImage(image, decode);
  }

  @override
  Future<AppNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AppNetworkImage>(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNetworkImage &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
