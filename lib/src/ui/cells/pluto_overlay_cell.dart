import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../widgets/dropdown/dropdown.dart';
import '../../widgets/dropdown/dropdown_theme.dart';
import 'package:flutter/cupertino.dart';

import 'text_cell.dart';

class PlutoOverlayCell extends StatefulWidget implements TextCell {
  @override
  final PlutoGridStateManager stateManager;

  @override
  final PlutoCell cell;

  @override
  final PlutoColumn column;

  @override
  final PlutoRow row;

  final int rowIdx;

  const PlutoOverlayCell({
    required this.stateManager,
    required this.cell,
    required this.column,
    required this.row,
    required this.rowIdx,
    super.key,
  });

  @override
  PlutoOverlayCellState createState() => PlutoOverlayCellState();
}

class PlutoOverlayCellState extends State<PlutoOverlayCell> {
  dynamic _initialCellValue;

  final _textController = TextEditingController();

  final PlutoDebounceByHashCode _debounce = PlutoDebounceByHashCode();

  final ScrollController _scrollController = ScrollController();

  late final FocusNode cellFocus;

  late _CellEditingStatus _cellEditingStatus;

  bool _showDropdown = false;


  @override
  TextInputType get keyboardType => TextInputType.text;

  @override
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
      _openOverlay();
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
    if(!widget.column.readOnly && widget.column.type.overlay.readOnly){
      _openOverlay();
    }
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


  void _openOverlay() async {
    if(_showDropdown != true){
      setState(() {
        _showDropdown = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stateManager.keepFocus) {
      cellFocus.requestFocus();
    }

    return DropdownTheme(
        data: Theme.of(context).brightness == Brightness.dark
            ? DropdownThemeData.dark()
            : DropdownThemeData.light(),
        child: MoonDropdown(
          groupId: widget.column.type.overlay.groupId,
          show: _showDropdown,
          constrainWidthToChild: false,
          onTapOutside: () => _handleDropdownTapOutside(),
          contentPadding: EdgeInsets.zero,
          dropdownAnchorPosition: MoonDropdownAnchorPosition.vertical,
          content: widget.column.type.overlay.overlayBuilder.call(widget.row,widget.cell,widget.rowIdx,context,(){
            setState(() {
              _showDropdown = false;
            });
          }),
          child: TextField(
            focusNode: cellFocus,
            controller: _textController,
            onEditingComplete: (){
              _changeValue();
            },
            onChanged: (_){
              _cellEditingStatus = _CellEditingStatus.changed;
            },
            readOnly: widget.column.type.overlay.readOnly,
            onTap: _handleOnTap,
            style: widget.stateManager.configuration.style.cellTextStyle,
            // onTapOutside: (PointerDownEvent _) => _handleInputTapOutside(),
            decoration: InputDecoration(
              suffix: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _openOverlay(),
                  child: const Icon(
                    CupertinoIcons.ellipsis,
                    size: 16,
                  ),
                ),
              ),
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
