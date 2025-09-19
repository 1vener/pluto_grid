import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/src/widgets/color_utils.dart';
import 'package:pluto_grid/src/widgets/macos_colors.dart';
import 'dropdown.dart';

typedef OptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function(
    TextEditingValue textEditingValue, Iterable<T> options);
typedef AllOptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function();

typedef ComboBoxInit = void Function(TextEditingController controller,FocusNode focusNode);
const _kFormTextStyle = TextStyle(fontSize: 13,fontWeight: FontWeight.w500);
const _kFormFieldHeight = 28.0;
class ComboBox<T extends Object> extends StatefulWidget {
  const ComboBox({
    super.key,
    this.onlySelected = false,
    required this.optionsBuilder,
    this.fieldViewBuilder,
    this.optionsViewBuilder,
    required this.allOptionsBuilder,
    this.onSelected,
    this.textFieldIcon,
    this.textFieldIconWidth,
    required this.onChanged,
    this.initValue,
    this.enabled = true,
    this.init,
    this.titleInLine = true,
    this.readonly = false,
  });

  /// input only selected options;
  final bool onlySelected;
  final OptionsBuilder<T> optionsBuilder;
  final AllOptionsBuilder<T> allOptionsBuilder;
  final AutocompleteFieldViewBuilder? fieldViewBuilder;
  final AutocompleteOptionsViewBuilder<T>? optionsViewBuilder;
  final AutocompleteOnSelected<T>? onSelected;
  final Widget? textFieldIcon;
  final double? textFieldIconWidth;
  final ValueChanged<String> onChanged;
  final T? initValue;
  final bool enabled;
  final ComboBoxInit? init;
  final bool titleInLine;
  final bool readonly;


  @override
  State<ComboBox<T>> createState() => _ComboBoxState<T>();
}

class _ComboBoxState<T extends Object> extends State<ComboBox<T>> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _searchController ;
  late ScrollController _scrollController;

  Iterable<T> _filteredOptionsList = [];
  Iterable<T> _options = [];
  String? _selectedOption;
  bool _showDropdown = false;
  int selectedIndex = 0;

  bool get _optionIsSelected => _selectedOption == _searchController.text;

  Future<void> _performSearch() async {
    if (_options.isEmpty) {
      _options = await widget.allOptionsBuilder();
    }
    var iterable =
    await widget.optionsBuilder(_searchController.value, _options);
    _filteredOptionsList = iterable.toList();
    setState(() {
      if (!_optionIsSelected && _selectedOption != null) _selectedOption = null;
      _showDropdown = true;
      widget.onChanged(_searchController.text);
    });
  }

  void _handleSelect(T option) {
    setState(() {
      _showDropdown = false;
      _searchController.text = option.toString();
      widget.onChanged(_searchController.text);
      _selectedOption = option.toString();
      _focusNode.unfocus();
      if (widget.onSelected != null) {
        widget.onSelected!(option);
      }
    });
  }

  void _showAllOptionsList() async {
    _options = await widget.allOptionsBuilder();
    setState(() {
      _filteredOptionsList = _options;
      _showDropdown = !_showDropdown;
    });
  }

  void _handleDropdownTapOutside() {
    setState(() {
      _showDropdown = false;
      if (!_optionIsSelected && widget.onlySelected && !_options.contains(_searchController.text)) _searchController.clear();
      _focusNode.unfocus();
      FocusScope.of(context).unfocus();
    });
  }

  void _handleInputTapOutside() {
    if (_focusNode.hasFocus && !_showDropdown) {
      if (!_optionIsSelected && widget.onlySelected && !_options.contains(_searchController.text)) _searchController.clear();
      _focusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    print('disopse men');
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    Brightness brightness = themeData.brightness;
    // maxWidth: constraint.maxWidth -
    //     textFieldIconWidth -
    //     textFieldIconPaddingWidth -4,
    // minWidth: constraint.maxWidth -
    // textFieldIconWidth -
    // textFieldIconPaddingWidth -4,
    Color fillColor = brightness == Brightness.dark
        ? widget.enabled == true ? MacosColors.textFieldBackground.darkColor :  const Color.fromRGBO(255, 255, 255, 0.01)
        : widget.enabled == true ? MacosColors.textFieldBackground.color :  const Color(0xfff6f6f9);
    Widget child = TextField(
      textAlignVertical: TextAlignVertical.center,
      style: _kFormTextStyle,
      maxLines: 1,
      cursorHeight: 13,
      controller: _searchController,
      focusNode: _focusNode,
      canRequestFocus: true,
      enabled: widget.enabled,
      readOnly: widget.readonly,
      // hintText: "Choose an option",
      onTap: () => _performSearch(),
      onTapOutside: (PointerDownEvent _) =>
          _handleInputTapOutside(),
      onChanged: (String _) => _performSearch(),
      decoration: InputDecoration(
        icon: widget.textFieldIcon != null && widget.titleInLine
            ? SizedBox(
          width: widget.textFieldIconWidth,
          child: widget.textFieldIcon,
        )
            : null,
        constraints: const BoxConstraints(
          maxHeight: _kFormFieldHeight,
          minHeight: _kFormFieldHeight,
          minWidth: 50.0,
        ),
        suffixIcon: GestureDetector(
          onTap: () => _showAllOptionsList(),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _showDropdown ? -0.5 : 0,
            child: const Icon(
              CupertinoIcons.chevron_down,
              size: 14,
            ),
          ),
        ),
        isCollapsed: false,
        filled: true,
        fillColor: fillColor,
        hoverColor: Colors.transparent,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
              color: brightness == Brightness.dark
                  ? MacosColors.disabledControlTextColor.darkColor
                  : MacosColors.disabledControlTextColor.color,
              width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5.0),
          borderSide: BorderSide(
              color: brightness == Brightness.dark
                  ? MacosColors.selectedControlTextColor.darkColor
                  : MacosColors.selectedControlTextColor.color,
              width: 1),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius:
            const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(
                color: themeData
                    .primaryColor
                    .withOpacity(0.2),
                width: 3)),
      ),
    );
    if(widget.titleInLine == false && widget.textFieldIcon != null){
      child  = Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: EdgeInsets.only(bottom: 6),child: widget.textFieldIcon!,),
          ),
          child
        ],
      );
    }
    return LayoutBuilder(builder: (context, constraint) {
      double textFieldIconWidth = widget.textFieldIconWidth ?? 0;
      ///textField decoration.icon has 16 padding at end @see InputDecorator line:2292 final Widget? icon = decoration.icon == null ? null :
      double textFieldIconPaddingWidth = 16;
      late double maxWidth;
      late double minWidth;
      late Offset offset ;
      if(textFieldIconWidth > 0){
        maxWidth = constraint.maxWidth -
            textFieldIconWidth -
            textFieldIconPaddingWidth -4;
        minWidth = constraint.maxWidth -
            textFieldIconWidth -
            textFieldIconPaddingWidth -4;
        offset = Offset((textFieldIconWidth + textFieldIconPaddingWidth) /2, 0);
      }else{
        maxWidth = constraint.maxWidth;
        minWidth = constraint.maxWidth;
        offset = const Offset(0, 0);
      }

      return MoonDropdown(
        maxHeight: 200,
        minHeight: 80,
        maxWidth: maxWidth,
        minWidth: minWidth,
        show: _showDropdown,
        borderColor: brightness == Brightness.dark
            ? const Color(0xFF3F3F3F)
            : const Color(0xFFE5E5E5),
        constrainWidthToChild: false,
        onTapOutside: () => _handleDropdownTapOutside(),
        contentPadding: EdgeInsets.zero,
        dropdownAnchorPosition: MoonDropdownAnchorPosition.vertical,
        offset: offset,
        content: widget.optionsViewBuilder != null
            ? widget.optionsViewBuilder!(
            context, _handleSelect, _filteredOptionsList)
            : Scrollbar(
          controller: _scrollController,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(4),
            controller: _scrollController,
            primary: false,
            itemCount: _filteredOptionsList.length,
            cacheExtent: 10,
            itemExtent: 22,
            itemBuilder: (BuildContext context, int index) {
              return TextButton(
                style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.hovered)) {
                        return themeData.primaryColor;
                      } else {
                        return Colors.transparent;
                      }
                    }),
                    maximumSize:
                    WidgetStateProperty.all(Size(100, 22)),
                    minimumSize:
                    WidgetStateProperty.all(Size(50, 22)),
                    animationDuration: Duration.zero,
                    // 设置文字颜色，使用textstyle无效
                    foregroundColor: WidgetStateProperty.resolveWith(
                            (Set<WidgetState> states) {
                          if (states.contains(WidgetState.hovered)) {
                            return ColorUtils.textLuminance(
                                themeData.primaryColor);
                          } else {
                            return brightness == Brightness.dark
                                ? MacosColors.labelColor.darkColor
                                : MacosColors.labelColor.color;
                          }
                        }),
                    shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)))),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_filteredOptionsList
                      .elementAt(index)
                      .toString(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onPressed: () {
                  if(!widget.readonly){
                    _handleSelect(
                        _filteredOptionsList.elementAt(index));
                  }

                },
              );
            },
          ),
        ),
        child: widget.fieldViewBuilder != null
            ? widget.fieldViewBuilder!(
            context, _searchController, _focusNode, () {})
            : child,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    print('init combobox');
    if(widget.initValue != null){
      _searchController = TextEditingController(text: widget.initValue.toString());
    }else{
      _searchController = TextEditingController();
    }

    _scrollController = ScrollController();
    widget.init?.call(_searchController,_focusNode);

  }

  @override
  void didUpdateWidget(ComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }
}
