import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../macos_colors.dart';

class DropdownThemeData {
  /// The border radius of the MoonDropdown.
  final BorderRadiusGeometry borderRadius;

  /// The distance between the MoonDropdown and the target child widget.
  final double distanceToTarget;

  /// The duration of the MoonDropdown transition animation (fade in or out).
  final Duration transitionDuration;

  /// The curve of the MoonDropdown transition animation (fade in or out).
  final Curve transitionCurve;

  /// The padding of the MoonDropdown content.
  final EdgeInsetsGeometry contentPadding;

  /// The margin of the MoonDropdown.
  final EdgeInsetsGeometry dropdownMargin;

  /// The text style of the MoonDropdown.
  final TextStyle textStyle;

  /// The text color of the MoonDropdown.
  final Color textColor;

  /// The icon color of the MoonDropdown.
  final Color iconColor;

  /// The background color of the MoonDropdown.
  final Color backgroundColor;

  /// The list of shadows applied to the MoonDropdown.
  List<BoxShadow> dropdownShadows;

  DropdownThemeData({
    required this.borderRadius,
    required this.distanceToTarget,
    required this.transitionDuration,
    required this.transitionCurve,
    required this.contentPadding,
    required this.dropdownMargin,
    required this.textStyle,
    required this.textColor,
    required this.iconColor,
    required this.backgroundColor,
    required this.dropdownShadows,
  });

  factory DropdownThemeData.dark() {
    return DropdownThemeData(
        borderRadius: BorderRadius.circular(5),
        distanceToTarget: 8.0,
        transitionDuration: Duration(milliseconds: 200),
        transitionCurve: Curves.easeInOutCubic,
        contentPadding: EdgeInsets.all(4),
        dropdownMargin: EdgeInsets.all(8),
        textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MacosColors.labelColor.darkColor),
        textColor: Colors.white,
        iconColor: Colors.white,
        backgroundColor: MacosColors.contentBackgroundColor.darkColor,
        dropdownShadows: [
          BoxShadow(
            color: Color(0x8E000000),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Color(0xA3000000),
            blurRadius: 6,
            offset: Offset(0, 6),
            spreadRadius: -6,
          ),
        ]
    );
  }

  factory DropdownThemeData.light() {
    return DropdownThemeData(
        borderRadius: BorderRadius.circular(5),
        distanceToTarget: 8.0,
        transitionDuration: Duration(milliseconds: 200),
        transitionCurve: Curves.easeInOutCubic,
        contentPadding: EdgeInsets.all(4),
        dropdownMargin: EdgeInsets.all(8),
        textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: MacosColors.labelColor.color),
        textColor: Colors.black,
        iconColor: Colors.black,
        backgroundColor: Colors.white,
        dropdownShadows: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 1,
          ),
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 6,
            offset: Offset(0, 6),
            spreadRadius: -6,
          ),
        ]);
  }
}

/// Applies a [TabbedView] theme to descendant widgets.
/// See also:
///
///  * [DropdownThemeData], which describes the actual configuration of a theme.
class DropdownTheme extends StatelessWidget {
  /// Applies the given theme [data] to [child].
  ///
  /// The [data] and [child] arguments must not be null.
  const DropdownTheme({
    Key? key,
    required this.child,
    required this.data,
  }) : super(key: key);

  /// Specifies the theme for descendant widgets.
  final DropdownThemeData data;

  /// The widget below this widget in the tree.
  final Widget child;

  static final DropdownThemeData _defaultTheme = DropdownThemeData.light();

  /// The data from the closest [DropdownTheme] instance that encloses the given
  /// context.
  static DropdownThemeData of(BuildContext context) {
    final _InheritedTheme? inheritedTheme =
    context.dependOnInheritedWidgetOfExactType<_InheritedTheme>();
    final DropdownThemeData data = inheritedTheme?.theme.data ?? _defaultTheme;
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedTheme(theme: this, child: child);
  }
}

class _InheritedTheme extends InheritedWidget {
  const _InheritedTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  final DropdownTheme theme;

  @override
  bool updateShouldNotify(_InheritedTheme old) => theme.data != old.theme.data;
}
