import 'package:flutter/material.dart';

class PlutoScaledCheckbox extends StatelessWidget {
  final bool? value;

  final Function(bool? changed) handleOnChanged;

  final bool tristate;

  final double scale;

  final Color unselectedColor;

  final Color? activeColor;


  const PlutoScaledCheckbox({
    super.key,
    required this.value,
    required this.handleOnChanged,
    this.tristate = false,
    this.scale = 1.0,
    this.unselectedColor = Colors.black26,
    this.activeColor = Colors.lightBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Theme(
        data: ThemeData(
          unselectedWidgetColor: unselectedColor,
        ),
        child: Checkbox(
          value: value,
          tristate: tristate,
          onChanged: handleOnChanged,
          activeColor: value == null ? unselectedColor : activeColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
          side: BorderSide(
            color: value ?? false ? (activeColor ?? Colors.blue) : Colors.grey,
            width: 1.5,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          // checkColor: checkColor,
        ),
      ),
    );
  }
}
