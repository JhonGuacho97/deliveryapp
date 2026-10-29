import 'package:flutter/material.dart';
import 'package:planck/constants/constants.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.padding = const EdgeInsets.all(kDefaultPadding * 0.85),
  });

  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding * .5),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: padding,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Flexible(child: Text(text, textAlign: TextAlign.center))],
        ),
      ),
    );
  }
}
