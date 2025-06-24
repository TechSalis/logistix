import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:logistix/features/map/presentation/widgets/__map_box_widget.dart';

import '../../../../../../test_helpers.dart';

void main() {
  testWidgets('tests MapViewWidget', (tester) async {
    await tester.pumpWidget(materialAppWrapper(child: const MapViewWidget()));

    expect(find.byType(MapViewWidget), findsOneWidget);
    expect(find.byType(MapView), findsOneWidget);
  });
}
