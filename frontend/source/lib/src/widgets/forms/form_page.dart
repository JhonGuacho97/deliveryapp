import 'package:flutter/material.dart';
import 'package:delivery_app/src/widgets/modal_progress_hud.dart';

ThemeData cleanFormTheme(ThemeData theme) => theme.copyWith(
  scaffoldBackgroundColor: theme.colorScheme.surface,
  appBarTheme: theme.appBarTheme.copyWith(
    backgroundColor: theme.colorScheme.surface,
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: theme.outlinedButtonTheme.style?.copyWith(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: theme.filledButtonTheme.style?.copyWith(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    ),
  ),
  dialogTheme: theme.dialogTheme.copyWith(
    backgroundColor: theme.colorScheme.surface,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
);

class FormPage extends StatelessWidget {
  const FormPage({
    super.key,
    required this.child,
    this.title,
    this.formKey,
    this.footer,
    this.busy = false,
    this.onChanged,
    this.actions,
    this.showAppBar = true,
  });
  final Widget child;
  final String? title;
  final GlobalKey<FormState>? formKey;
  final Widget? footer;
  final bool busy, showAppBar;
  final VoidCallback? onChanged;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) => Theme(
    data: cleanFormTheme(Theme.of(context)),
    child: Builder(
      builder: (context) => Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: title == null ? null : Text(title!),
                actions: actions,
              )
            : null,
        body: SafeArea(
          top: !showAppBar,
          child: ModalProgressHUD(
            inAsyncCall: busy,
            child: Form(
              key: formKey,
              onChanged: onChanged,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: const ValueKey('form-scroll'),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                  if (footer != null)
                    Padding(
                      key: const ValueKey('form-footer'),
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                      child: Align(
                        alignment: Alignment.center,
                        heightFactor: 1,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 580),
                          child: SizedBox(
                            width: double.infinity,
                            child: footer!,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    super.key,
    required this.child,
    required this.actions,
    this.title,
    this.formKey,
  });
  final Widget child;
  final List<Widget> actions;
  final String? title;
  final GlobalKey<FormState>? formKey;
  @override
  Widget build(BuildContext context) => Theme(
    data: cleanFormTheme(Theme.of(context)),
    child: AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      title: title == null ? null : Text(title!),
      content: SizedBox(
        width: 480,
        child: Form(key: formKey, child: child),
      ),
      actions: actions,
    ),
  );
}
