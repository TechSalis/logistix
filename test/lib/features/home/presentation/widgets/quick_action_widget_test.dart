import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistix/features/home/presentation/widgets/quick_action_widget.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_enum.dart';

import '../../../../../test_helpers.dart';

void main() {
  group('tests QuickActionWidget rendering and functionality', () {
    testWidgets('verifies widget renders properly', (tester) async {
      await tester.pumpWidget(
        materialAppWrapper(
          child: QuickActionWidget(action: QuickAction.groceries, onTap: () {}),
        ),
      );

      expect(find.byIcon(QuickAction.groceries.icon), findsOneWidget);
      expect(find.text(QuickAction.groceries.name), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
        QuickAction.groceries.color,
      );
    });
    testWidgets('verifies onTap functions properly', (tester) async {
      bool isTapped = false;
      await tester.pumpWidget(
        materialAppWrapper(
          child: QuickActionWidget(
            action: QuickAction.errands,
            onTap: () => isTapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(QuickActionWidget));
      expect(isTapped, true);
    });
  });
}
