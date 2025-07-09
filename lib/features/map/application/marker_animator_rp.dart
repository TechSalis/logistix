// lib/features/map/application/rider_marker_animator.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/presentation/coordinate_tween.dart';

const kMapStreamPeriodDuration = Duration(seconds: 5);

class MarkerAnimator
    extends AutoDisposeFamilyNotifier<Coordinates?, MarkerAnimatorParams> {
  late final AnimationController _controller;
  Animation<Coordinates>? _animation;

  @override
  Coordinates? build(MarkerAnimatorParams param) {
    _controller = AnimationController(vsync: arg.vsync, duration: arg.duration);
    ref.onDispose(_controller.dispose);

    return state = param.initialPosition;
  }

  void _updateAnimationListener() => state = _animation!.value;

  void updatePosition(Coordinates newPosition) {
    if (state == null) {
      state = newPosition;
      return;
    }

    _animation = CoordinateTween(
      begin: state!,
      end: newPosition,
    ).animate(_controller)..addListener(_updateAnimationListener);
    ref.onDispose(() => _animation!.removeListener(_updateAnimationListener));

    _controller.forward(from: 0);
  }

  void dispose() => ref.invalidateSelf();
}

final markerAnimatorProvider = NotifierProvider.autoDispose.family(
  MarkerAnimator.new,
);

class MarkerAnimatorParams extends Equatable {
  final TickerProvider vsync;
  final Coordinates? initialPosition;
  final Duration duration;

  const MarkerAnimatorParams({
    required this.vsync,
    this.duration = kMapStreamPeriodDuration,
    this.initialPosition,
  });

  @override
  List<Object?> get props => [vsync];
}
