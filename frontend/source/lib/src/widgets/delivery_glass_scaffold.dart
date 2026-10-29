import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Shared floating navigation for customers, restaurants and couriers.
/// Material's scaffold measures the complete dock (including the cart) and
/// exposes its height through MediaQuery.padding.bottom to the scroll views.
class DeliveryGlassScaffold extends StatefulWidget {
  const DeliveryGlassScaffold({
    super.key,
    required this.appBar,
    required this.body,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.bottomAccessory,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final List<GlassTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Widget? bottomAccessory;

  @override
  State<DeliveryGlassScaffold> createState() => _DeliveryGlassScaffoldState();
}

class _DeliveryGlassScaffoldState extends State<DeliveryGlassScaffold> {
  final _contentScope = GlobalKey<GlassContentAwareScopeState>();
  int? _pointer;
  int? _pendingIndex;
  int _gestureEpoch = 0;
  int _lensEpoch = 0;
  bool _awaitingRelease = false;
  bool _cancelled = false;

  void _sampleAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _contentScope.currentState?.requestSample();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sampleAfterLayout();
  }

  @override
  void didUpdateWidget(covariant DeliveryGlassScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) _sampleAfterLayout();
  }

  void _select(int index) {
    if (_cancelled) return;
    // The package can report selection on touch-down or cancellation. Keep
    // visual scrubbing local; update the screen and fetch data only on release.
    if (_awaitingRelease) {
      setState(() => _pendingIndex = index);
    } else {
      _commit(index); // Keyboard and screen-reader activation have no pointer.
    }
  }

  void _commit(int index) {
    if (index == widget.selectedIndex) return;
    FocusScope.of(context).unfocus();
    widget.onTabSelected(index);
  }

  void _release(PointerUpEvent event) {
    if (_pointer != event.pointer) return;
    _pointer = null;
    final epoch = _gestureEpoch;
    // Drag-end runs after the raw pointer listener. Wait for its final target.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || epoch != _gestureEpoch || _pointer != null) return;
      _awaitingRelease = false;
      final index = _pendingIndex;
      _pendingIndex = null;
      if (index != null) _commit(index);
    });
  }

  void _cancel(PointerCancelEvent event) {
    if (_pointer != event.pointer) return;
    _pointer = null;
    _pendingIndex = null;
    _awaitingRelease = false;
    _cancelled = true;
    // Recreate the lens on the host's current tab after an OS interruption.
    setState(() {
      _gestureEpoch++;
      _lensEpoch++;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _cancelled = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return GlassTheme(
      data: GlassThemeData.simple(
        brightness: theme.brightness,
        quality: GlassQuality.standard,
        blur: 8,
      ),
      child: GlassAccessibilityScope(
        child: GlassPage(
          child: GlassContentAwareScope(
            key: _contentScope,
            backgroundColor: theme.scaffoldBackgroundColor,
            flipDuration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 200),
            child: Scaffold(
              appBar: widget.appBar,
              extendBody: true,
              body: GlassContentAwareContent(
                child: Material(
                  color: theme.scaffoldBackgroundColor,
                  child: widget.body,
                ),
              ),
              bottomNavigationBar: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 4),
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ?widget.bottomAccessory,
                        Listener(
                          key: const ValueKey('delivery-glass-navigation'),
                          onPointerDown: (event) {
                            if (_pointer != null) return;
                            _pointer = event.pointer;
                            _pendingIndex = null;
                            _awaitingRelease = true;
                            _cancelled = false;
                            _gestureEpoch++;
                          },
                          onPointerUp: _release,
                          onPointerCancel: _cancel,
                          child: GlassContentAwareBrightness(
                            builder: _buildNavigation,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigation(
    BuildContext context,
    Brightness brightness,
    double darkAmount,
  ) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final textScale = MediaQuery.textScalerOf(context).scale(13) / 13;
    final barHeight = 70.0 + (textScale - 1).clamp(0.0, 2.0) * 20;
    final selected = Color.lerp(
      const Color(0xFF155C42),
      const Color(0xFFAFF4D1),
      darkAmount,
    )!;
    final unselected = Color.lerp(
      const Color(0xFF17251E),
      Colors.white,
      darkAmount,
    )!;
    final halo = Color.lerp(
      Colors.white,
      Colors.black,
      darkAmount,
    )!.withValues(alpha: .8);
    final shadows = [Shadow(color: halo, blurRadius: 2)];
    Widget? shadowed(Widget? icon) => icon == null
        ? null
        : IconTheme.merge(
            data: IconThemeData(shadows: shadows),
            child: icon,
          );
    return GlassTheme(
      data: GlassThemeData.simple(
        brightness: brightness,
        quality: GlassQuality.standard,
        blur: 10,
      ),
      child: GlassTabBar.bottom(
        key: ValueKey('glass-lens-$_lensEpoch'),
        tabs: [
          for (final tab in widget.tabs)
            GlassTab(
              icon: shadowed(tab.icon),
              activeIcon: shadowed(tab.activeIcon),
              label: tab.label,
              semanticLabel: tab.semanticLabel,
              glowColor: tab.glowColor,
              thickness: tab.thickness,
            ),
        ],
        selectedIndex: _pendingIndex ?? widget.selectedIndex,
        onTabSelected: _select,
        horizontalPadding: 16,
        verticalPadding: 10,
        // Keep the original translucent material. The content-aware scope
        // changes the glyphs instead of covering photographs with a white fill.
        settings: LiquidGlassSettings(
          glassColor: Color.lerp(
            const Color(0x33FFFFFF),
            const Color(0x330B1510),
            darkAmount,
          )!,
          thickness: 30,
          blur: 10,
          refractiveIndex: 1.59,
          saturation: .9,
          lightIntensity: .6,
          ambientStrength: 1,
          chromaticAberration: .2,
        ),
        barHeight: barHeight,
        barBorderRadius: 36,
        iconSize: 24,
        labelFontSize: 13,
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          shadows: shadows,
        ),
        unselectedLabelStyle: TextStyle(shadows: shadows),
        selectedIconColor: selected,
        selectedLabelColor: selected,
        unselectedIconColor: unselected,
        unselectedLabelColor: unselected,
        indicatorColor: Color.lerp(
          const Color(0x40FFFFFF),
          const Color(0x33000000),
          darkAmount,
        ),
        interactionGlowColor: Colors.white.withValues(alpha: .12),
        glowOpacity: .08,
        glowBlurRadius: 12,
        magnification: reduceMotion ? 1 : 1.22,
        pressScale: reduceMotion ? 1 : 1.025,
        indicatorExpansion: reduceMotion
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        maskingQuality: MaskingQuality.high,
      ),
    );
  }
}
