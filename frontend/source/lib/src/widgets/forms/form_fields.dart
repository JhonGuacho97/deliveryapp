import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:planck/constants/constants.dart';
import 'package:planck/generated/l10n.dart';

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.helper,
  });
  final String label;
  final Widget child;
  final bool required;
  final String? helper;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ExcludeSemantics(
        child: Text(
          label + (required ? '*' : ''),
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(height: 8),
      Semantics(label: label, child: child),
      if (helper != null && helper!.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(helper!, style: Theme.of(context).textTheme.bodySmall),
      ],
    ],
  );
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.required = true,
    this.suffixIcon,
    this.inputFormatters,
    this.autofillHints,
    this.helper,
  });
  final String label;
  final String? hint, initialValue, helper;
  final TextEditingController? controller;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final int? minLines, maxLines, maxLength;
  final bool enabled, readOnly, obscureText, required;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  @override
  Widget build(BuildContext context) => FormFieldLabel(
    label: label,
    required: required,
    helper: helper,
    child: TextFormField(
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      controller: controller,
      initialValue: initialValue,
      onSaved: onSaved,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      autofillHints: autofillHints,
      scrollPadding: const EdgeInsets.all(28),
      decoration: InputDecoration(
        hintText: hint,
        errorMaxLines: 3,
        suffixIcon: suffixIcon,
        fillColor: !enabled
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : null,
      ),
    ),
  );
}

class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    this.initialValue,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.textInputAction = TextInputAction.done,
  });
  final String label;
  final String? initialValue;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _hidden = true;
  @override
  Widget build(BuildContext context) => AppTextField(
    label: widget.label,
    initialValue: widget.initialValue,
    onSaved: widget.onSaved,
    onChanged: widget.onChanged,
    validator: widget.validator,
    keyboardType: TextInputType.visiblePassword,
    textInputAction: widget.textInputAction,
    obscureText: _hidden,
    suffixIcon: IconButton(
      tooltip: _hidden
          ? S.of(context).showPassword
          : S.of(context).hidePassword,
      onPressed: () => setState(() => _hidden = !_hidden),
      icon: Icon(
        _hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
      ),
    ),
  );
}

class AppPhoneField extends StatefulWidget {
  const AppPhoneField({
    super.key,
    required this.label,
    this.initialValue = '',
    this.onSaved,
    this.onChanged,
    this.onEdited,
    this.helper,
    this.preserveUnchanged = false,
  });
  final String label, initialValue;
  final String? helper;
  final ValueChanged<String>? onSaved, onChanged;
  final VoidCallback? onEdited;
  final bool preserveUnchanged;
  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  bool _changed = false;
  String get _initial => widget.initialValue.startsWith('0')
      ? widget.initialValue.substring(1)
      : widget.initialValue;
  @override
  Widget build(BuildContext context) => FormFieldLabel(
    label: widget.label,
    required: true,
    helper: widget.helper,
    child: IntlPhoneField(
      initialCountryCode: kCountryCode,
      initialValue: _initial,
      disableLengthCheck: true,
      decoration: const InputDecoration(errorMaxLines: 3, counterText: ''),
      textInputAction: TextInputAction.next,
      invalidNumberMessage: S.of(context).eValidatoPhone,
      validator: (phone) {
        final number = phone?.number.replaceAll(RegExp(r'\D'), '') ?? '';
        final full = phone?.completeNumber ?? '';
        return number.isEmpty || full.length < 10 || full.length > 19
            ? S.of(context).eValidatoPhone
            : null;
      },
      onChanged: (phone) {
        _changed = true;
        widget.onEdited?.call();
        widget.onChanged?.call(phone.completeNumber);
      },
      onCountryChanged: (_) {
        _changed = true;
        widget.onEdited?.call();
      },
      onSaved: (phone) => widget.onSaved?.call(
        widget.preserveUnchanged && !_changed
            ? widget.initialValue
            : phone?.completeNumber ?? '',
      ),
    ),
  );
}

class FormReadOnlyValue extends StatelessWidget {
  const FormReadOnlyValue({
    super.key,
    required this.label,
    required this.value,
    this.helper,
  });
  final String label, value;
  final String? helper;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleLarge),
          if (helper != null) ...[
            const SizedBox(height: 6),
            Text(helper!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
