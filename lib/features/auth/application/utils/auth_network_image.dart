import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';

class NetworkImageWithAuth extends ImageProvider<NetworkImageWithAuth> {
  final String url;

  const NetworkImageWithAuth(this.url);

  @override
  ImageStreamCompleter loadImage(
    NetworkImageWithAuth key,
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
  Future<NetworkImageWithAuth> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImageWithAuth>(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NetworkImageWithAuth &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
