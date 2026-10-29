import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> reviewLiquidNavigation(
  WidgetTester tester,
  IntegrationTestWidgetsFlutterBinding binding, {
  required int Function() selectedIndex,
  required String role,
}) async {
  final bar = find.byType(GlassTabBar);
  final rect = tester.getRect(bar).deflate(16);
  final first = Offset(rect.left + rect.width / 6, rect.center.dy);
  final last = Offset(rect.right - rect.width / 6, rect.center.dy);
  await binding.takeScreenshot('ui-glass-$role');
  final gesture = await tester.startGesture(first);
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.moveTo(first + const Offset(24, 0));
  await tester.pump(const Duration(milliseconds: 80));
  await gesture.moveTo(rect.center);
  await tester.pump(const Duration(milliseconds: 250));
  expect(selectedIndex(), 0, reason: 'The page changes only after release');
  await binding.takeScreenshot('ui-glass-$role-drag');
  await gesture.moveTo(last);
  await tester.pump(const Duration(milliseconds: 200));
  expect(selectedIndex(), 0);
  await gesture.up();
  await tester.pumpAndSettle();
  expect(selectedIndex(), 2);
  await binding.takeScreenshot('ui-glass-$role-account');
  await tester.tapAt(first);
  await tester.pumpAndSettle();
  expect(selectedIndex(), 0);
  expect(tester.takeException(), isNull);
}
