import 'package:flutter/material.dart';
import 'macos_colors.dart';


class BasicButton extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color hoverColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapDownCallback? onSecondaryTapDown;
  final double? width;
  final double? height;
  final BoxDecoration decoration;

  const BasicButton({
    Key? key,
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.hoverColor = MacosColors.hoverColor,
    this.borderRadius = 0,
    this.padding = const EdgeInsets.all(2.0),
    this.onTap,
    this.onDoubleTap,
    this.onSecondaryTapDown,
    this.width,
    this.height,
    this.decoration = const BoxDecoration(),
  }) : super(key: key);

  @override
  _BasicButtonState createState() => _BasicButtonState();
}

class _BasicButtonState extends State<BasicButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      onSecondaryTapDown: widget.onSecondaryTapDown,
      onDoubleTap: widget.onDoubleTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: widget.decoration.copyWith(
            color: _isHovered ? widget.hoverColor : widget.backgroundColor,
            borderRadius:
                _isHovered ? BorderRadius.circular(widget.borderRadius) : null,
          ),
          child: Padding(
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
