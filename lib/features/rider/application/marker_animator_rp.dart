// lib/features/map/application/rider_marker_animator.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location/domain/entities/coordinate.dart';
import 'package:logistix/features/map/presentation/coordinate_tween.dart';

class MarkerAnimator
    extends AutoDisposeFamilyNotifier<Coordinates?, MarkerAnimatorParams> {
  MarkerAnimator();

  late final AnimationController _controller;
  Animation<Coordinates>? _animation;
  Coordinates? _previous;

  Coordinates? get animatedValue => _animation?.value;

  @override
  Coordinates? build(MarkerAnimatorParams param) {
    ref.listen(arg.stream, (p, n) {
      if (n.hasValue) updatePosition(n.value!);
    });

    _controller = AnimationController(vsync: arg.vsync, duration: arg.duration);
    ref.onDispose(_controller.dispose);
    return null;
  }

  void updatePosition(Coordinates newPosition) {
    if (state == null) {
      state = newPosition;
      return;
    }

    _previous = state;
    final tween = CoordinateTween(begin: _previous!, end: newPosition);

    _animation = tween.animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addListener(() => state = _animation!.value);

    _controller.forward(from: 0);
  }
}

final markerAnimatorProvider = NotifierProvider.autoDispose.family(
  MarkerAnimator.new,
);

class MarkerAnimatorParams extends Equatable {
  final Duration duration;
  final TickerProvider vsync;
  final ProviderListenable<AsyncValue<Coordinates>> stream;

  const MarkerAnimatorParams({
    required this.vsync,
    required this.stream,
    this.duration = const Duration(seconds: 5),
  });

  @override
  List<Object?> get props => [vsync];
}
