import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_app/theme.dart';

void main() {
  testWidgets('both palettes keep readable text and action contrast', (
    tester,
  ) async {
    late ThemeData light;
    late ThemeData dark;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            light = lightThemeData(context);
            dark = darkThemeData(context);
            return const Scaffold(body: Text('Delivery'));
          },
        ),
      ),
    );
    double contrast(Color a, Color b) {
      final x = a.computeLuminance();
      final y = b.computeLuminance();
      return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
    }

    for (final theme in [light, dark]) {
      final scheme = theme.colorScheme;
      expect(
        contrast(scheme.primary, scheme.onPrimary),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onSurfaceVariant, theme.scaffoldBackgroundColor),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(scheme.onSurface, scheme.surface),
        greaterThanOrEqualTo(4.5),
      );
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Inter');
      expect(theme.textTheme.bodyMedium!.fontSize, greaterThanOrEqualTo(16));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('the application font is bundled for offline rendering', (
    tester,
  ) async {
    final font = await rootBundle.load('assets/fonts/Inter-Variable.ttf');
    expect(font.lengthInBytes, greaterThan(1000));
  });
}
