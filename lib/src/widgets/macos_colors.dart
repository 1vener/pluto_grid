import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MacosColors {
  /// A fully transparent color.
  static const Color transparent = Color(0x00000000);

  /// A fully opaque black color.
  static const black = Color(0xff000000);

  /// A fully opaque white color.
  static const white = Color(0xffffffff);

  /// The text of a label containing primary content.
  static const labelColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.85),
    darkColor: Color.fromRGBO(255, 255, 255, 0.85),
  );

  /// The text of a label of lesser importance than a primary label, such as
  /// a label used to represent a subheading or additional information.
  static const secondaryLabelColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.5),
    darkColor: Color.fromRGBO(255, 255, 255, 0.55),
  );

  /// The text of a label of lesser importance than a secondary label such as
  /// a label used to represent disabled text.
  static const tertiaryLabelColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.26),
    darkColor: Color.fromRGBO(255, 255, 255, 0.26),
  );

  /// The text of a label of lesser importance than a tertiary label such as
  /// watermark text.
  static const quaternaryLabelColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    darkColor: Color.fromRGBO(255, 255, 255, 0.1),
  );

  static const systemRedColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffFF3B30),
    darkColor: Color(0xffFF453A),
  );

  static const systemGreenColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xff34C759),
    darkColor: Color(0xff30D158),
  );

  static const systemBlueColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xff007AFF),
    darkColor: Color(0xff0A84FF),
  );

  static const systemOrangeColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffFF9500),
    darkColor: Color(0xffFF9F0A),
  );

  static const systemYellowColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffFF9F0A),
    darkColor: Color(0xffFFD60A),
  );

  static const systemBrownColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffA2845E),
    darkColor: Color(0xffAC8E68),
  );

  static const systemPinkColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffFF2D55),
    darkColor: Color(0xffFF375F),
  );

  static const systemPurpleColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffAF52DE),
    darkColor: Color(0xffBF5AF2),
  );

  static const systemTealColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xff55BEF0),
    darkColor: Color(0xff5AC8F5),
  );

  static const systemIndigoColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xff5856D6),
    darkColor: Color(0xff5E5CE6),
  );

  static const systemGrayColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xff8E8E93),
    darkColor: Color(0xff98989D),
  );

  /// A link to other content.
  static const linkColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xff0068DA),
    darkColor: Color.fromRGBO(65, 156, 255, 1),
  );

  /// A placeholder string in a control or text view.
  static const placeholderTextColor = Color(0xff737473);

  static const windowFrameColor = Color(0xffddddde);

  /// The text of a selected menu.
  static const selectedMenuItemTextColor = Color(0xfffeffff);

  /// The text on a selected surface in a list or table.
  static const alternateSelectedControlTextColor = Colors.white;

  ///	The text of a header cell in a table.
  static const headerTextColor = Colors.white;

  ///	A separator between different sections of content.
  static const separatorColor = Color(0xff39373c);

  ///	The gridlines of an interface element such as a table.
  static const gridColor = Color(0xff39373c);

  ///	The text in a document.
  static const textColor = Colors.white;

  ///	Text background.
  static const textBackgroundColor = Color(0xff1e1e1e);

  ///	Selected text.
  static const selectedTextColor = Colors.white;

  ///	The background of selected text.
  static const selectedTextBackgroundColor = Color(0xff3f638b);

  /// A background for selected text in a non-key window or view.
  static const unemphasizedSelectedTextBackgroundColor =
  CupertinoDynamicColor.withBrightness(
    color: Color(0xffDCDCDC),
    darkColor: Color(0xff464646),
  );

  /// Selected text in a non-key window or view.
  static const unemphasizedSelectedTextColor = Colors.white;

  /// The background of a window.
  static const windowBackgroundColor = Color(0xff3b373d);

  /// The background behind a document's content.
  static const underPageBackgroundColor = Color(0xff282828);

  /// The background of a large interface element, such as a browser or table.
  static const controlBackgroundColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffFFFFFF),
    darkColor: Color(0xff1E1E1E),
  );

  static const selectedControlBackgroundColor = Color(0xff0058d0);

  /// The selected content in a non-key window or view.
  static const unemphasizedSelectedContentBackgroundColor =
  Color(0xff464646);

  static const alternatingContentBackgroundColor = Color(0xff2e2c31);

  /// The color of a find indicator.
  ///
  /// Has no dark variant.
  static const findHighlightColor = Color(0xffffff00);

  /// The surface of a control.
  static const controlColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    darkColor: Color.fromRGBO(255, 255, 255, 0.25),
  );

  /// The text of a control that isn’t disabled.
  static const controlTextColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.85),
    darkColor: Color(0xffddddde),
  );

  /// The text of a control that’s disabled.
  static const disabledControlTextColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    darkColor: Color.fromRGBO(255, 255, 255, 0.25),
  );

  /// The surface of a selected control.
  static const selectedControlColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(179, 215, 255, 1.0),
    darkColor: Color.fromRGBO(63, 99, 139, 1.0),
  );

  /// The text of a selected control.
  static const selectedControlTextColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffddddde),
    darkColor: Color(0xff5a585c),
  );

  /// The ring that appears around the currently focused control when using
  /// the keyboard for interface navigation.
  static const keyboardFocusIndicatorColor =
  CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 103, 244, 0.25),
    darkColor: Color.fromRGBO(26, 169, 255, 0.3),
  );

  /// The color of the thumb of [MacosSlider].
  static const sliderThumbColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(255, 255, 255, 1.0),
    darkColor: Color.fromRGBO(152, 152, 157, 1.0),
  );

  /// The color of the tick marks which are not selected (the portion to the right of the thumb) of [MacosSlider].
  static const tickBackgroundColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(220, 220, 220, 1.0),
    darkColor: Color.fromRGBO(70, 70, 70, 1.0),
  );

  /// The color of the slider in [MacosSlider] which is not selected (the portion
  /// to the right of the thumb).
  static const sliderBackgroundColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(0, 0, 0, 0.1),
    darkColor: Color.fromRGBO(255, 255, 255, 0.1),
  );

  static const tableHighlightColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(244,245,245, 1.0),
    darkColor: Color.fromRGBO(48,42,46, 1.0),
  );

  static const tableBackgroundColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(255,255,255, 1.0),
    darkColor: Color.fromRGBO(37,32,36, 1.0),
  );

  static const tableColumnDividerColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(239,240,239, 1.0),
    darkColor: Color.fromRGBO(53,53,53, 1.0),
  );

  static const tableHeaderDividerColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(229,229,229, 1.0),
    darkColor: Color.fromRGBO(38,32,36, 1.0),
  );
  static const tableSortIconColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(159,159,159, 1.0),
    darkColor: Color.fromRGBO(128,123,126, 1.0),
  );
  static const tableScrollbarTrackColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(250,250,250, 1.0),
    darkColor: Color.fromRGBO(43,43,43, 1.0),
  );

  static const menuBackgroundColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(237, 237, 237, 1.0),
    darkColor: Color.fromRGBO(39, 39, 39, 1.0),
  );

  static const hoverColor = CupertinoDynamicColor.withBrightness(
    color: Color(0xffF3F2F2),
    darkColor: Color(0xff333336),
  );

  static const contentBackgroundColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(235,235,237, 1.0),
    darkColor: Color.fromRGBO(45,45,48, 1.0),
  );

  static const controlAccentColor = Color.fromRGBO(0, 122, 255, 1);

  static const menuBorderColor = CupertinoDynamicColor.withBrightness(
    color: Color.fromRGBO(187, 187, 187, 1),
    darkColor: Color.fromRGBO(82, 82, 82, 1),
  );

  static const  treeIconColor= CupertinoDynamicColor.withBrightness(
    color: Color(0xff7D8084),
    darkColor: Color(0xff929598),
  );

  static const  primaryIconColor= CupertinoDynamicColor.withBrightness(
    color: Color(0xff306EED),
    darkColor: Color(0xff3478F6),
  );

  static const  textFillColorPrimary= CupertinoDynamicColor.withBrightness(
    color: const Color(0xe4000000),
    darkColor: const Color(0xFFffffff),
  );

  static const  textFillColorSecondary= CupertinoDynamicColor.withBrightness(
    color: const Color(0x9e000000),
    darkColor: const Color(0xc5ffffff),
  );

  static const  textFillColorDisabled= CupertinoDynamicColor.withBrightness(
    color: const Color(0x5c000000),
    darkColor: const Color(0x5dffffff),
  );

  static const  solidBackgroundFillColorTertiary= CupertinoDynamicColor.withBrightness(
    color:  const Color(0xFFf9f9f9),
    darkColor: const Color(0xFF282828),
  );

  static const  layerOnMicaBaseAltFillColorDefault= CupertinoDynamicColor.withBrightness(
    color: const Color(0xb3ffffff),
    darkColor: const Color(0x733a3a3a),
  );

  static const  layerOnMicaBaseAltFillColorSecondary= CupertinoDynamicColor.withBrightness(
    color: const Color(0x0a000000),
    darkColor: const Color(0x0fffffff),
  );

  static const  layerOnMicaBaseAltFillColorTransparent= CupertinoDynamicColor.withBrightness(
    color: const Color(0x00ffffff),
    darkColor: const Color(0x00000000),
  );

  static const  selectTabBackground= CupertinoDynamicColor.withBrightness(
    color: const Color(0xFFE8E8E8),
    darkColor: const Color(0xFF535353),
  );

  static const  hoverTabBackground= CupertinoDynamicColor.withBrightness(
    color: const Color(0x0a000000),
    darkColor: const Color(0x0fffffff),
  );

  static const  textFieldBackground= CupertinoDynamicColor.withBrightness(
    color: white,
    darkColor: const Color.fromRGBO(30, 30, 30, 1),
  );



  static const appleBlue = Color(0xff0433ff);
  static const appleBrown = Color(0xffaa7942);
  static const appleCyan = Color(0xff00fdff);
  static const appleGreen = Color(0xff00f900);
  static const appleMagenta = Color(0xffff40ff);
  static const appleOrange = Color(0xffff9300);
  static const applePurple = Color(0xff0942192);
  static const appleRed = Color(0xffff2600);
  static const appleYellow = Color(0xfffffb00);
}
