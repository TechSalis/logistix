import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/constants/hive_constants.dart';

extension HiveExt on HiveInterface {
  Future<void> openStartupBoxes<T>() async {
    await Future.wait(HiveConstants.startupBoxes.map(Hive.openBox));
  }

  Future<void> openTrackedBoxes<T>() async {
    final boxNames = await Hive.openBox(
      HiveConstants.trackedBoxes,
    ).then<Iterable<String>>((box) => box.keys.cast<String>());
    await Future.wait(boxNames.map(Hive.openBox));
  }

  Future<Box<T>> openTrackedBox<T>(String name) {
    if (!Hive.isBoxOpen(name)) {
      Hive.box(HiveConstants.trackedBoxes).put(name, true);
    }
    return openBox<T>(name);
  }
}
