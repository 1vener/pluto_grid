import 'dart:ui';

import 'package:flutter/cupertino.dart';

class ColorUtils{
  static Color textLuminance(Color backgroundColor) {
    return backgroundColor.computeLuminance() >= 0.5
        ? CupertinoColors.black
        : CupertinoColors.white;
  }

  static Color helpIconLuminance(Color backgroundColor, bool isDark) {
    return !isDark
        ? backgroundColor.computeLuminance() > 0.5
        ? CupertinoColors.black
        : CupertinoColors.white
        : backgroundColor.computeLuminance() < 0.5
        ? CupertinoColors.black
        : CupertinoColors.white;
  }
  //反转颜色
  static Color invertColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      255 - color.red,
      255 - color.green,
      255 - color.blue,
    );
  }

}