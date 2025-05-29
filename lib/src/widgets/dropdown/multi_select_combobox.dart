import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/src/widgets/color_utils.dart';
import 'package:pluto_grid/src/widgets/dropdown/combobox.dart';
import 'package:pluto_grid/src/widgets/dropdown/dropdown_theme.dart';
import 'package:pluto_grid/src/widgets/macos_colors.dart';
import 'dropdown.dart';


typedef ComboBoxOnSelected<T extends Object> = void Function(T option,bool isSelected);

typedef ComboBoxOptionsViewBuilder<T extends Object> =
Widget Function(
    BuildContext context,
    ComboBoxOnSelected<T> onSelected,
    Iterable<T> options,
    );

const _kFormFieldHeigh = 28.0;
class MultiSelectComboBox<T extends Object> extends StatefulWidget {
  const MultiSelectComboBox({
    super.key,
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
  });

  final OptionsBuilder<T> optionsBuilder;
  final AllOptionsBuilder<T> allOptionsBuilder;
  final AutocompleteFieldViewBuilder? fieldViewBuilder;
  final ComboBoxOptionsViewBuilder<T>? optionsViewBuilder;
  final AutocompleteOnSelected<T>? onSelected;
  final Widget? textFieldIcon;
  final double? textFieldIconWidth;
  final ValueChanged<String> onChanged;
  final T? initValue;
  final bool enabled;
  final ComboBoxInit? init;
  final bool titleInLine;


  @override
  State<MultiSelectComboBox<T>> createState() => _MultiSelectComboBoxState<T>();
}

class _MultiSelectComboBoxState<T extends Object> extends State<MultiSelectComboBox<T>> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _textController ;
  late ScrollController _scrollController;
  late TextEditingController _searchController;

  Iterable<T> _filteredOptionsList = [];
  Iterable<T> _options = [];
  bool _showDropdown = false;


  final Map<T, bool> _selectedOptions = {};

  Future<void> _performSearch() async {
    if (_options.isEmpty) {
      _options = await widget.allOptionsBuilder();
    }
    var iterable =
    await widget.optionsBuilder(_searchController.value, _options);
    _filteredOptionsList = iterable.toList();
    setState(() {

      widget.onChanged(_textController.text);
    });
  }

  void _handleSelect(T option,bool selected) {
    setState(() {
      selected ? _selectedOptions[option] = true : _selectedOptions.remove(option);
      _textController.text = _selectedOptions.keys.map((e)=>e.toString()).join(',');
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
      _focusNode.unfocus();
      FocusScope.of(context).unfocus();
    });
  }

  void _handleInputTapOutside() {
    if (_focusNode.hasFocus && !_showDropdown) {
      _focusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    Color fillColor = Theme.of(context).brightness == Brightness.dark
        ? widget.enabled == true ? MacosColors.textFieldBackground.darkColor :  const Color.fromRGBO(255, 255, 255, 0.01)
        : widget.enabled == true ? MacosColors.textFieldBackground.color :  const Color(0xfff6f6f9);
    Widget child = TextField(
      textAlignVertical: TextAlignVertical.center,
      style:  const TextStyle(fontSize: 13, height: 1),
      maxLines: 1,
      cursorHeight: 13,
      controller: _textController,
      focusNode: _focusNode,
      canRequestFocus: true,
      enabled: widget.enabled,
      // hintText: "Choose an option",
      onTapOutside: (PointerDownEvent _) =>
          _handleInputTapOutside(),
      // onChanged: (String _) => _performSearch(),
      decoration: InputDecoration(
        icon: widget.textFieldIcon != null && widget.titleInLine
            ? SizedBox(
          width: widget.textFieldIconWidth,
          child: widget.textFieldIcon,
        )
            : null,
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
        // isCollapsed: false,
        // filled: true,
        // hoverColor: Colors.transparent,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.zero,
        filled: true,
        fillColor: fillColor,
      ),
      readOnly: true,
    );
    if(widget.titleInLine == false && widget.textFieldIcon != null){
      child  = Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(padding: const EdgeInsets.only(bottom: 6),child: widget.textFieldIcon!,),
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

      return DropdownTheme(
          data: Theme.of(context).brightness == Brightness.dark
              ? DropdownThemeData.dark()
              : DropdownThemeData.light(),
          child: MoonDropdown(
            maxHeight: 200,
            minHeight: 80,
            maxWidth: maxWidth,
            minWidth: minWidth,
            show: _showDropdown,
            borderColor: Theme.of(context).brightness == Brightness.dark
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
                : _buildOptionsView(),
            child: widget.fieldViewBuilder != null
                ? widget.fieldViewBuilder!(
                context, _textController, _focusNode, () {})
                : child,
          ));
    });
  }

  @override
  void initState() {
    super.initState();
    if(widget.initValue != null){
      _textController = TextEditingController(text: widget.initValue.toString());
    }else{
      _textController = TextEditingController();
    }
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    widget.init?.call(_textController,_focusNode);

  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();

  }

  @override
  void didUpdateWidget(MultiSelectComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Widget _buildOptionsView(){
    Widget optionsContent = Scrollbar(
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
          bool isSelected = _selectedOptions.containsKey(_filteredOptionsList.elementAt(index));
          return _buildMenuItem(context, index, isSelected);
        },
      ),
    );
    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            textAlignVertical: TextAlignVertical.center,
            style:  const TextStyle(fontSize: 13, height: 1),
            maxLines: 1,
            cursorHeight: 13,
            controller: _searchController,
            canRequestFocus: true,
            onChanged: (String _) => _performSearch(),
            decoration: InputDecoration(
              prefixIcon: const Padding(padding: EdgeInsets.only(left: 4,top: 4,bottom: 4),child: Icon(CupertinoIcons.search,size: _kFormFieldHeigh - 8,),),
              prefixIconConstraints: const BoxConstraints(maxWidth:  _kFormFieldHeigh,minWidth:  _kFormFieldHeigh),
              isCollapsed: false,
              filled: false,
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(
                maxHeight: _kFormFieldHeigh,
                minHeight: _kFormFieldHeigh,
                minWidth: 50.0,
              ),
              contentPadding:
              const EdgeInsets.only(top:0,bottom:8,right: 8),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const Divider(height: 1,),
          optionsContent
        ],
      ),
    );

  }
  Widget _buildMenuItem(BuildContext context, int index,bool isSelected){
    late Widget item = Row(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(_filteredOptionsList
            .elementAt(index)
            .toString()),
      ),
      const Spacer(),
      Checkbox(
        splashRadius: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).primaryColor;
          }
          return null;
        }),
        side: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xff5a585c)
                : const Color(0xffddddde),
            width: 1),
        value: isSelected,
        onChanged: (bool? _) {
          _handleSelect(
              _filteredOptionsList.elementAt(index),!isSelected);
        },
      )
    ]);
    return TextButton(
      style: ButtonStyle(
          backgroundColor:
          WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Theme.of(context).primaryColor;
            } else {
              return Colors.transparent;
            }
          }),
          maximumSize:
          WidgetStateProperty.all(const Size(100, 22)),
          minimumSize:
          WidgetStateProperty.all(const Size(50, 22)),
          animationDuration: Duration.zero,
          // 设置文字颜色，使用textstyle无效
          foregroundColor: WidgetStateProperty.resolveWith(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.hovered)) {
                  return ColorUtils.textLuminance(
                      Theme.of(context).primaryColor);
                } else {
                  return Theme.of(context).brightness == Brightness.dark
                      ? MacosColors.labelColor.darkColor
                      : MacosColors.labelColor.color;
                }
              }),
          shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)))),
      child: item,
      onPressed: () {
        _handleSelect(
            _filteredOptionsList.elementAt(index),!isSelected);
      },
    );
  }
}

