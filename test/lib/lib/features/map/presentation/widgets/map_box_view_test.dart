import 'package:flutter_test/flutter_test.dart';
import 'package:logistix/features/map/presentation/widgets/map_box_view.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../../../../../test_helpers.dart';

void main() {
  testWidgets('tests MapViewWidget', (tester) async {
    await tester.pumpWidget(materialAppWrapper(child: MapViewWidget()));

    expect(find.byType(MapViewWidget), findsOneWidget);
    expect(find.byType(MapWidget), findsOneWidget);
  });
}
