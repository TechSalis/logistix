import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistix/features/quick_actions/presentation/widgets/quick_action_widget.dart';
import 'package:logistix/features/quick_actions/domain/quick_actions_types.dart';

import '../../../../../test_helpers.dart';

void main() {
  group('tests QuickActionWidget rendering and functionality', () {
    testWidgets('verifies widget renders properly', (tester) async {
      await tester.pumpWidget(
        materialAppWrapper(
          child: QuickActionWidget(
            action: QuickActionType.groceries,
            onTap: () {},
          ),
        ),
      );

      expect(find.byIcon(QuickActionType.groceries.icon), findsOneWidget);
      expect(find.text(QuickActionType.groceries.label), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(
        tester.widget<CircleAvatar>(find.byType(CircleAvatar)).backgroundColor,
        QuickActionType.groceries.color,
      );
    });
    testWidgets('verifies onTap functions properly', (tester) async {
      bool isTapped = false;
      await tester.pumpWidget(
        materialAppWrapper(
          child: QuickActionWidget(
            action: QuickActionType.errands,
            onTap: () => isTapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(QuickActionWidget));
      expect(isTapped, true);
    });
  });
}
