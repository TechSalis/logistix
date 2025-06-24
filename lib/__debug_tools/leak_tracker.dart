import 'package:flutter/foundation.dart';
import 'package:leak_tracker/leak_tracker.dart';

void trackLeaks() {
  FlutterMemoryAllocations.instance.addListener(
    (ObjectEvent event) => LeakTracking.dispatchObjectEvent(event.toMap()),
  );
  LeakTracking.declareNotDisposedObjectsAsLeaks();
  LeakTracking.phase = const PhaseSettings(
    leakDiagnosticConfig: LeakDiagnosticConfig(collectStackTraceOnStart: true),
  );
  LeakTracking.start();
}
