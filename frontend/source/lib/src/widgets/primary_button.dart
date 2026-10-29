import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.85),
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final EdgeInsets padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding * .5),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: color == null ? null : Colors.white,
          minimumSize: const Size(double.infinity, 52),
          padding: padding,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(child: Text(text, textAlign: TextAlign.center)),
            if (icon != null) const SizedBox(width: 12),
            if (icon != null) Icon(icon),
          ],
        ),
      ),
    );
  }
}
