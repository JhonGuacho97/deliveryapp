import 'dart:async';

import 'package:flutter/material.dart';
import 'package:delivery_app/generated/l10n.dart';
import 'package:delivery_app/src/services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

// Open our own origin first: PayPhone validates the referring domain registered
// in Developer. Android localhost reaches the PC through adb reverse in tests.
Uri? payphoneBridgeUrl(Object? value, String baseUrl) {
  if (value is! String) return null;
  final uri = Uri.tryParse(value), base = Uri.tryParse(baseUrl);
  if (uri == null ||
      base == null ||
      uri.userInfo.isNotEmpty ||
      uri.hasQuery ||
      uri.hasFragment ||
      !RegExp(r'^/api/client/payments/payphone/start/[a-f0-9]{24}$')
          .hasMatch(uri.path))
    return null;
  const loopbacks = {'localhost', '127.0.0.1', '::1', '10.0.2.2'};
  final local =
      loopbacks.contains(base.host) &&
      loopbacks.contains(uri.host) &&
      base.scheme == 'http' &&
      uri.scheme == 'http' &&
      base.port == uri.port;
  return local || (uri.scheme == 'https' && uri.origin == base.origin)
      ? uri
      : null;
}

class PayphoneCheckoutScreen extends StatefulWidget {
  const PayphoneCheckoutScreen({
    super.key,
    required this.payment,
    required this.service,
    this.launcher,
    this.pollInterval = const Duration(seconds: 3),
  });

  final Map<String, dynamic> payment;
  final PaymentService service;
  final Future<bool> Function(Uri)? launcher;
  final Duration pollInterval;

  @override
  State<PayphoneCheckoutScreen> createState() => _PayphoneCheckoutScreenState();
}

class _PayphoneCheckoutScreenState extends State<PayphoneCheckoutScreen>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _checking = false, _opening = false, _offline = false, _active = true;
  int _status = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(widget.pollInterval, (_) => _check());
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) _check();
  }

  Future<void> _check() async {
    if (_checking || !_active || !mounted || _status != 1) return;
    setState(() => _checking = true);
    final result = await widget.service.status(widget.payment['id'] as int);
    if (!mounted) return;
    final matches =
        result?['id'] == widget.payment['id'] &&
        result?['provider'] == 'payphone';
    setState(() {
      _checking = false;
      _offline = !matches;
      if (matches && {1, 100, 400}.contains(result?['status']))
        _status = result!['status'] as int;
    });
    if (_status == 100) {
      _timer?.cancel();
      Navigator.of(context).pop(true);
    } else if (_status == 400) {
      _timer?.cancel();
    }
  }

  Future<void> _open() async {
    final response = widget.payment['response'];
    final uri = payphoneBridgeUrl(
      response is Map ? response['checkoutUrl'] : null,
      widget.service.baseUrl,
    );
    if (uri == null || _opening) return;
    setState(() => _opening = true);
    bool opened = false;
    try {
      opened =
          await (widget.launcher?.call(uri) ??
              launchUrl(uri, mode: LaunchMode.externalApplication));
    } catch (_) {}
    if (!mounted) return;
    setState(() => _opening = false);
    if (!opened)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).paymentBrowserError)),
      );
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), theme = Theme.of(context);
    final response = widget.payment['response'];
    final validLink =
        payphoneBridgeUrl(
          response is Map ? response['checkoutUrl'] : null,
          widget.service.baseUrl,
        ) !=
        null;
    return Scaffold(
      appBar: AppBar(title: const Text('PayPhone')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(
                _status == 400 ? Icons.info_outline : Icons.lock_outline,
                size: 44,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                s.paymentCheckoutTitle,
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${(widget.payment['money'] as num).toStringAsFixed(2)} USD',
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                _status == 400 ? s.paymentDeclined : s.paymentCheckoutHelp,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (_status == 1) ...[
                FilledButton.icon(
                  onPressed: validLink && !_opening ? _open : null,
                  icon: const Icon(Icons.open_in_browser),
                  label: Text(s.paymentOpenBrowser),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _checking ? null : _check,
                  icon: const Icon(Icons.refresh),
                  label: Text(s.paymentCheckStatus),
                ),
                const SizedBox(height: 16),
                Text(
                  !validLink
                      ? s.paymentBrowserError
                      : _offline
                      ? s.paymentConnectionError
                      : s.paymentPending,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(s.paymentBackToCart),
              ),
              if (_status == 1)
                Text(
                  s.paymentResumeHelp,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
