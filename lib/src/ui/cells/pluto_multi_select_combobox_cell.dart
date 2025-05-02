import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/helper/platform_helper.dart';
import '../../widgets/dropdown/dropdown.dart';
import '../../widgets/dropdown/dropdown_theme.dart';
import '../../widgets/color_utils.dart';
import '../../widgets/macos_colors.dart';
import 'package:flutter/cupertino.dart';

import 'text_cell.dart';
const _kFormFieldHeigh = 28.0;
class PlutoMultiSelectComboBoxCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  const PlutoMultiSelectComboBoxCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    super.key,
  });

  @override
  PlutoMultiSelectComboBoxCellState createState() => PlutoMultiSelectComboBoxCellState();
}

class PlutoMultiSelectComboBoxCellState extends State<PlutoMultiSelectComboBoxCell> {
  dynamic _initialCellValue;

  final _textController = TextEditingController();
  final _searchController = TextEditingController();

  final PlutoDebounceByHashCode _debounce = PlutoDebounceByHashCode();

  final ScrollController _scrollController = ScrollController();

  late final FocusNode cellFocus;

  late _CellEditingStatus _cellEditingStatus;

  bool _showDropdown = false;

  Iterable<String> _options = [];
  Iterable<String> _filteredOptionsList = [];
  final Map<String, bool> _selectedOptions = {};

  TextInputType get keyboardType => TextInputType.text;

  List<TextInputFormatter>? get inputFormatters => [];

  String get formattedValue =>
      widget.column.formattedValueForDisplayInEditing(widget.cell.value);

  @override
  void initState() {
    super.initState();

    cellFocus = FocusNode(onKeyEvent: _handleOnKey);

    widget.stateManager.setTextEditingController(_textController);

    _textController.text = formattedValue;

    _initialCellValue = _textController.text;

    _cellEditingStatus = _CellEditingStatus.init;

    _textController.addListener(() {
      _handleOnChanged(_textController.text.toString());
    });

    if(_textController.text.isNotEmpty){
      List<String> list = _textController.text.split(widget.column.type.multiSelect.splitStr);
      for (var value in list) {
        _selectedOptions[value] = true;
      }
    }
  }

  @override
  void dispose() {
    /**
     * Saves the changed value when moving a cell while text is being input.
     * if user do not press enter key, onEditingComplete is not called and the value is not saved.
     */
    if (_cellEditingStatus.isChanged) {
      _changeValue();
    }

    if (!widget.stateManager.isEditing ||
        widget.stateManager.currentColumn?.enableEditingMode != true) {
      widget.stateManager.setTextEditingController(null);
    }

    _debounce.dispose();

    _textController.dispose();
    _searchController.dispose();
    cellFocus.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  void _restoreText() {
    if (_cellEditingStatus.isNotChanged) {
      return;
    }

    _textController.text = _initialCellValue.toString();

    widget.stateManager.changeCellValue(
      widget.stateManager.currentCell!,
      _initialCellValue,
      notify: false,
    );
  }

  bool _moveHorizontal(PlutoKeyManagerEvent keyManager) {
    if (!keyManager.isHorizontal) {
      return false;
    }

    if (widget.column.readOnly == true) {
      return true;
    }

    final selection = _textController.selection;

    if (selection.baseOffset != selection.extentOffset) {
      return false;
    }

    if (selection.baseOffset == 0 && keyManager.isLeft) {
      return true;
    }

    final textLength = _textController.text.length;

    if (selection.baseOffset == textLength && keyManager.isRight) {
      return true;
    }

    return false;
  }

  void _changeValue() {
    if(formattedValue == _textController.text){
      return;
    }
    widget.stateManager.changeCellValue(widget.cell, _textController.text);

    _cellEditingStatus = _CellEditingStatus.updated;
  }

  Future<void> _handleOnChanged(String value) async {
    _cellEditingStatus = formattedValue != value.toString()
        ? _CellEditingStatus.changed
        : _initialCellValue.toString() == value.toString()
            ? _CellEditingStatus.init
            : _CellEditingStatus.updated;
    _performSearch();
  }

  Future<void> _performSearch() async {
    if (_options.isEmpty) {
      List<dynamic> list = await widget.column.type.multiSelect.optionsBuilder.call();
      _options = list.map((e) => e.toString())
          .toList();
    }

    _filteredOptionsList = _options.where((String option) {
      return option.toLowerCase().contains(_searchController.text.toLowerCase());
    });
    if (mounted) {
      setState(() {
        // if (!_optionIsSelected && _selectedOption != null) _selectedOption = null;
        // _showDropdown = true;
      });
    }
  }

  void _handleOnComplete() {
    final old = _textController.text;

    _changeValue();

    _handleOnChanged(old);

    PlatformHelper.onMobile(() {
      widget.stateManager.setKeepFocus(false);
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  KeyEventResult _handleOnKey(FocusNode node, KeyEvent event) {
    var keyManager = PlutoKeyManagerEvent(
      focusNode: node,
      event: event,
    );

    if (keyManager.isKeyUpEvent) {
      return KeyEventResult.handled;
    }

    final skip = !(keyManager.isVertical ||
        _moveHorizontal(keyManager) ||
        keyManager.isEsc ||
        keyManager.isTab ||
        keyManager.isF3 ||
        keyManager.isEnter);

    // 이동 및 엔터키, 수정불가 셀의 좌우 이동을 제외한 문자열 입력 등의 키 입력은 텍스트 필드로 전파 한다.
    if (skip) {
      return widget.stateManager.keyManager!.eventResult.skip(
        KeyEventResult.ignored,
      );
    }

    if (_debounce.isDebounced(
      hashCode: _textController.text.hashCode,
      ignore: !kIsWeb,
    )) {
      return KeyEventResult.handled;
    }

    // 엔터키는 그리드 포커스 핸들러로 전파 한다.
    if (keyManager.isEnter) {
      _handleOnComplete();
      return KeyEventResult.ignored;
    }

    // ESC 는 편집된 문자열을 원래 문자열로 돌이킨다.
    if (keyManager.isEsc) {
      _restoreText();
    }

    // KeyManager 로 이벤트 처리를 위임 한다.
    widget.stateManager.keyManager!.subject.add(keyManager);

    // 모든 이벤트를 처리 하고 이벤트 전파를 중단한다.
    return KeyEventResult.handled;
  }

  void _handleOnTap() {
    widget.stateManager.setKeepFocus(true);
  }

  void _handleDropdownTapOutside() {
    setState(() {
      _showDropdown = false;
      widget.stateManager.setKeepFocus(false);
      cellFocus.unfocus();
      FocusScope.of(context).unfocus();
    });
    _changeValue();
  }

  void _handleInputTapOutside() {
    widget.stateManager.setKeepFocus(false);
  }

  void _handleSelect(String option,bool isSelected) {
    isSelected ? _selectedOptions[option] = true : _selectedOptions.remove(option);
    _textController.text = _selectedOptions.keys.map((e)=>e.toString()).join(',');
    _changeValue();
  }

  void _showAllOptionsList() async {
    List<dynamic> list = await widget.column.type.multiSelect.optionsBuilder.call();
    _options = list.map((e) => e.toString())
        .toList();
    setState(() {
      _filteredOptionsList = _options;
      _showDropdown = !_showDropdown;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    return LayoutBuilder(builder: (ctx,constraint){
      return  DropdownTheme(
          data: Theme.of(context).brightness == Brightness.dark
              ? DropdownThemeData.dark()
              : DropdownThemeData.light(),
          child: MoonDropdown(
            groupId: widget.column.type.multiSelect.groupId,
            maxHeight: 200,
            minHeight: 80,
            maxWidth: constraint.maxWidth,
            minWidth: constraint.minWidth,
            show: _showDropdown,
            constrainWidthToChild: false,
            onTapOutside: () => _handleDropdownTapOutside(),
            contentPadding: EdgeInsets.zero,
            dropdownAnchorPosition: MoonDropdownAnchorPosition.vertical,
            content: _buildOptionsView(),
            child: TextField(
              focusNode: cellFocus,
              controller: _textController,
              readOnly: true,
              onChanged: _handleOnChanged,
              onEditingComplete: _handleOnComplete,
              onSubmitted: (_) => _handleOnComplete(),
              onTap: _handleOnTap,
              style: widget.stateManager.configuration.style.cellTextStyle,
              onTapOutside: (PointerDownEvent _) => _handleInputTapOutside(),
              decoration: InputDecoration(
                suffix: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => _showAllOptionsList(),
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: _showDropdown ? -0.5 : 0,
                      child: const Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                      ),
                    ),
                  ),
                ),
                // suffixIcon: GestureDetector(
                //   onTap: () => _showAllOptionsList(),
                //   child: AnimatedRotation(
                //     duration: const Duration(milliseconds: 200),
                //     turns: _showDropdown ? -0.5 : 0,
                //     child: const Icon(
                //       CupertinoIcons.chevron_down,
                //       size: 14,
                //     ),
                //   ),
                // ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: 1,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              textAlignVertical: TextAlignVertical.center,
              textAlign: widget.column.textAlign.value,
            ),
          ));
    },);
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
            style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w500),
            maxLines: 1,
            cursorHeight: 13,
            controller: _searchController,
            canRequestFocus: true,
            onChanged: (String _) => _performSearch(),
            decoration: InputDecoration(
              prefixIcon: const Padding(padding: EdgeInsets.only(left: 4,top: 4,bottom: 4),child: Icon(CupertinoIcons.search,size:  _kFormFieldHeigh - 8,),),
              prefixIconConstraints: const BoxConstraints(maxWidth:   _kFormFieldHeigh,minWidth:   _kFormFieldHeigh),
              isCollapsed: false,
              filled: false,
              hoverColor: Colors.transparent,
              constraints: const BoxConstraints(
                maxHeight:  _kFormFieldHeigh,
                minHeight:  _kFormFieldHeigh,
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
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
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
                ? MacosColors.selectedControlTextColor.darkColor
                : MacosColors.selectedControlTextColor.color,
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
          WidgetStateProperty.all(Size(100, 22)),
          minimumSize:
          WidgetStateProperty.all(Size(50, 22)),
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
        print('select item');
        _handleSelect(
            _filteredOptionsList.elementAt(index),!isSelected);
      },
    );
  }
}

enum _CellEditingStatus {
  init,
  changed,
  updated;

  bool get isNotChanged {
    return _CellEditingStatus.changed != this;
  }

  bool get isChanged {
    return _CellEditingStatus.changed == this;
  }

  bool get isUpdated {
    return _CellEditingStatus.updated == this;
  }
}
