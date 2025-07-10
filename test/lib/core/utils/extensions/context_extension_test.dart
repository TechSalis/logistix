import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logistix/core/theme/theme.dart';
import 'package:logistix/core/theme/extensions/context_extension.dart';

void main() {
  Future<void> buildWidget(WidgetTester tester, ThemeMode themeMode) async {
    await tester.pumpWidget(
      MaterialApp(
        themeMode: themeMode,
        theme: MyTheme.light,
        darkTheme: MyTheme.dark,
        home: const Material(),
      ),
    );
  }

  group('tests ContextExtension functions properly', () {
    testWidgets('verifies isLightTheme is true', (tester) async {
      await buildWidget(tester, ThemeMode.light);
      final context = tester.element(find.byType(Material));
      expect(context.isLightTheme, true);
      expect(context.isDarkTheme, false);
    });
    testWidgets('verifies isDarkTheme is true', (tester) async {
      await buildWidget(tester, ThemeMode.dark);
      final context = tester.element(find.byType(Material));
      expect(context.isDarkTheme, true);
      expect(context.isLightTheme, false);
    });
  });
}
