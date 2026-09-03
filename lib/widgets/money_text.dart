import 'package:flutter/material.dart';

/// Displays a money/number value that is ALWAYS fully visible — never
/// truncated with an ellipsis, which looks broken in RTL layouts. Instead,
/// the text shrinks to fit its available space, and is always rendered
/// left-to-right regardless of the app's current locale/text direction,
/// since currency values should read LTR even in an Arabic RTL app.
class MoneyText extends StatelessWidget {
  final String value;
  final TextStyle? style;
  final TextAlign? textAlign;
  const MoneyText(this.value, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: textAlign == TextAlign.right ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(value, style: style, maxLines: 1),
      ),
    );
  }
}
