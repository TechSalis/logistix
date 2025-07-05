import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistix/features/new_order/widgets/order_icon.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_types.dart';

import '../../../../../test_helpers.dart';

void main() {
  group('tests QuickActionWidget rendering and functionality', () {
    testWidgets('verifies widget renders properly', (tester) async {
      await tester.pumpWidget(
        materialAppWrapper(
          child: QuickActionWidget(
            action: OrderType.groceries,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(OrderType.groceries.icon), findsOneWidget);
      expect(find.text(OrderType.groceries.label), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
        OrderType.groceries.color,
      );
    });
    testWidgets('verifies onTap functions properly', (tester) async {
      bool isTapped = false;
      await tester.pumpWidget(
        materialAppWrapper(
          child: QuickActionWidget(
            action: OrderType.errands,
            onTap: () => isTapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(QuickActionWidget));
      expect(isTapped, true);
    });
  });
}
