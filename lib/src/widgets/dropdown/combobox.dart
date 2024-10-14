import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../macos_colors.dart';
import '../color_utils.dart';

import 'dropdown.dart';

typedef OptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function(
    TextEditingValue textEditingValue, Iterable<T> options);
typedef AllOptionsBuilder<T extends Object> = FutureOr<Iterable<T>> Function();

typedef ComboBoxInit = void Function(TextEditingController controller,FocusNode focusNode);
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
      if (!_optionIsSelected && widget.onlySelected) _searchController.clear();
      _focusNode.unfocus();
      FocusScope.of(context).unfocus();
    });
  }

  void _handleInputTapOutside() {
    if (_focusNode.hasFocus && !_showDropdown) {
      if (!_optionIsSelected && widget.onlySelected) _searchController.clear();
      _focusNode.unfocus();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build combobox');
    return LayoutBuilder(builder: (context, constraint) {
      double textFieldIconWidth = widget.textFieldIconWidth ?? 0;

      ///textField decoration.icon has 16 padding at end @see InputDecorator line:2292 final Widget? icon = decoration.icon == null ? null :
      double textFieldIconPaddingWidth = 16;
      return MoonDropdown(
        maxHeight: 200,
        show: _showDropdown,
        constrainWidthToChild: true,
        onTapOutside: () => _handleDropdownTapOutside(),
        contentPadding: EdgeInsets.zero,
        dropdownAnchorPosition: MoonDropdownAnchorPosition.bottomRight,
        backgroundColor: Color.fromRGBO(250, 250, 250, 1),
        content: widget.optionsViewBuilder != null
            ? widget.optionsViewBuilder!(
                context, _handleSelect, _filteredOptionsList)
            : ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: constraint.maxWidth -
                        textFieldIconWidth -
                        textFieldIconPaddingWidth -4),
                child: Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
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
                                return Theme.of(context).primaryColor;
                              } else {
                                return Colors.transparent;
                              }
                            }),
                            maximumSize: WidgetStateProperty.all(Size(100, 22)),
                            minimumSize: WidgetStateProperty.all(Size(50, 22)),
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
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              _filteredOptionsList.elementAt(index).toString()),
                        ),
                        onPressed: () {
                          _handleSelect(_filteredOptionsList.elementAt(index));
                        },
                      );
                    },
                  ),
                ),
              ),
        child: widget.fieldViewBuilder != null
            ? widget.fieldViewBuilder!(
                context, _searchController, _focusNode, () {})
            : TextField(
                textAlignVertical: TextAlignVertical.center,
                style: const TextStyle(fontSize: 13, height: 1),
                maxLines: 1,
                cursorHeight: 13,
                controller: _searchController,
                focusNode: _focusNode,
                canRequestFocus: true,
                enabled: widget.enabled,
                // hintText: "Choose an option",
                onTapOutside: (PointerDownEvent _) => _handleInputTapOutside(),
                onChanged: (String _) => _performSearch(),
                onEditingComplete: () {
                  print('onEditingComplete:${_searchController.value}');
                },
                onSubmitted: (value) {
                  print('onSubmitted:$value');
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
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
