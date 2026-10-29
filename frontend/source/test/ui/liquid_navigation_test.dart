import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:planck/src/widgets/delivery_glass_scaffold.dart';
import 'package:planck/theme.dart';

const _tabs = [
  GlassTab(icon: Icon(Icons.explore_outlined), label: 'Explorar'),
  GlassTab(icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
  GlassTab(icon: Icon(Icons.person_outline_rounded), label: 'Cuenta'),
];

Future<void> navigationReviewApp(
  WidgetTester tester, {
  bool dark = false,
  bool reduceMotion = false,
  bool highContrast = false,
  bool rtl = false,
  double scale = 1,
  Widget? accessory,
  ValueChanged<int>? onSelected,
}) async {
  var selected = 0;
  await tester.pumpWidget(
    Builder(
      builder: (context) => MaterialApp(
        theme: dark ? darkThemeData(context) : lightThemeData(context),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: reduceMotion,
            highContrast: highContrast,
            padding: const EdgeInsets.only(bottom: 24),
            viewPadding: const EdgeInsets.only(bottom: 24),
            textScaler: TextScaler.linear(scale),
          ),
          child: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        ),
        home: StatefulBuilder(
          builder: (context, setState) => DeliveryGlassScaffold(
            appBar: AppBar(title: Text('Pantalla $selected')),
            selectedIndex: selected,
            tabs: _tabs,
            onTabSelected: (index) {
              setState(() => selected = index);
              onSelected?.call(index);
            },
            bottomAccessory: accessory,
            body: Builder(
              builder: (context) => ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom + 20,
                ),
                children: [
                  for (var i = 0; i < 25; i++)
                    ListTile(title: Text('Producto $i')),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Última acción'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _bar => find.byType(GlassTabBar);

void main() {
  testWidgets('pressing another tab previews it until the finger is released', (
    tester,
  ) async {
    final selections = <int>[];
    await navigationReviewApp(tester, onSelected: selections.add);
    final rect = tester.getRect(_bar).deflate(16);
    final gesture = await tester.startGesture(rect.center);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Pantalla 0'), findsOneWidget);
    expect(tester.widget<GlassTabBar>(_bar).selectedIndex, 1);
    expect(selections, isEmpty);
    await gesture.moveBy(const Offset(24, 0));
    await tester.pump(const Duration(milliseconds: 80));
    await gesture.moveTo(Offset(rect.right - rect.width / 6, rect.center.dy));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selections, [2]);
    expect(find.text('Pantalla 2'), findsOneWidget);
  });

  testWidgets('held drag magnifies the lens and commits one tab on release', (
    tester,
  ) async {
    final selections = <int>[];
    await navigationReviewApp(tester, onSelected: selections.add);
    final rect = tester.getRect(_bar).deflate(16);
    final gesture = await tester.startGesture(
      Offset(rect.left + rect.width / 6, rect.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.moveTo(rect.center);
    await tester.pump(const Duration(milliseconds: 200));
    expect(selections, isEmpty, reason: 'Scrubbing must not reload every page');
    expect(find.text('Pantalla 0'), findsOneWidget);
    expect(tester.widget<GlassTabBar>(_bar).magnification, greaterThan(1));
    await gesture.moveTo(Offset(rect.right - rect.width / 6, rect.center.dy));
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(selections, [2]);
    expect(find.text('Pantalla 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled drag leaves the current page and future taps work', (
    tester,
  ) async {
    final selections = <int>[];
    await navigationReviewApp(tester, onSelected: selections.add);
    final rect = tester.getRect(_bar).deflate(16);
    final gesture = await tester.startGesture(
      Offset(rect.left + rect.width / 6, rect.center.dy),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await gesture.moveTo(rect.center);
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.cancel();
    await tester.pumpAndSettle();
    expect(selections, isEmpty);
    await tester.tapAt(Offset(rect.right - rect.width / 6, rect.center.dy));
    await tester.pumpAndSettle();
    expect(selections, [2]);
    expect(find.text('Pantalla 2'), findsOneWidget);
  });

  for (final dark in [false, true]) {
    testWidgets(
      '320 px glass dock fits large text, cart and bottom inset: $dark',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await navigationReviewApp(
          tester,
          dark: dark,
          scale: 2,
          accessory: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FilledButton(
              onPressed: () {},
              child: const Text('Ver carrito'),
            ),
          ),
        );
        final barRect = tester.getRect(_bar);
        expect(barRect.bottom, lessThanOrEqualTo(720 - 24));
        expect(
          tester.getRect(find.text('Ver carrito')).bottom,
          lessThan(barRect.top),
        );
        await tester.scrollUntilVisible(find.text('Última acción'), 300);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(find.text('Última acción')).bottom,
          lessThan(tester.getRect(find.text('Ver carrito')).top),
        );
        await tester.tap(find.text('Última acción'));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('reduced motion and high contrast retain accessible navigation', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await navigationReviewApp(tester, reduceMotion: true, highContrast: true);
    expect(tester.widget<GlassTabBar>(_bar).magnification, 1);
    final account = find.bySemanticsLabel('Cuenta');
    expect(account, findsOneWidget);
    final node = tester.getSemantics(account);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.binding.rootPipelineOwner.visitChildren((owner) {
      owner.semanticsOwner?.performAction(node.id, SemanticsAction.tap);
    });
    await tester.pumpAndSettle();
    expect(find.text('Pantalla 2'), findsOneWidget);
    expect(
      tester
          .getSemantics(account)
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      ui.Tristate.isTrue,
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('keyboard and RTL taps use the same selected page', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await navigationReviewApp(tester, rtl: true);
    final rect = tester.getRect(_bar).deflate(16);
    await tester.tapAt(Offset(rect.left + rect.width / 6, rect.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('Pantalla 2'), findsOneWidget);
    tester
        .widget<FocusableActionDetector>(
          find
              .descendant(
                of: find.bySemanticsLabel('Pedidos'),
                matching: find.byType(FocusableActionDetector),
              )
              .first,
        )
        .focusNode!
        .requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('Pantalla 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
