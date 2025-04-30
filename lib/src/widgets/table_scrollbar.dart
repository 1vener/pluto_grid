import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/manager/pluto_grid_state_manager.dart';
import 'package:pluto_grid/src/ui/miscellaneous/pluto_state_with_change.dart';

class TableScrollbar extends PlutoStatefulWidget {
  final PlutoGridStateManager stateManager;
  final Axis direction;
  final double? height;
  final double? width;
  final ScrollController scrollController;

  const TableScrollbar({
    required this.stateManager,
    required this.direction,
    this.height,
    this.width,
    required this.scrollController
  });

  @override
  State<TableScrollbar> createState() => _TableScrollbarState();
}

class _TableScrollbarState extends PlutoStateWithChange<TableScrollbar> {
  late ChangeNotifier _resizingChangeNotifier;
   double _scrollWidth = 0;
   double _scrollHeight = 0;


  @override
  Widget build(BuildContext context) {
    double scrollBarSize = widget.stateManager.configuration.style.scrollBarSize;
    return
      LayoutBuilder(builder: (ctx,consts){
        return Container(
            decoration: BoxDecoration(color: Colors.transparent,),
            // padding: EdgeInsets.only(top: widget.direction == Axis.vertical ? 24 : 0,bottom: widget.direction == Axis.vertical ? 24 : 0),
            child: ScrollbarTheme(
              data: widget.stateManager.configuration.scrollbarThemeData ?? Theme.of(ctx).scrollbarTheme,
              child: Scrollbar(
                  controller: widget.scrollController,
                  child: SingleChildScrollView(
                      controller: widget.scrollController,
                      scrollDirection: widget.direction,
                      child: _buildSizeBox(consts,scrollBarSize))),));
      },);
  }

  Widget _buildSizeBox(BoxConstraints consts,double scrollBarSize){
    if(widget.direction == Axis.vertical){
      return SizedBox(
        width: scrollBarSize,height: max(_scrollHeight, consts.maxHeight),);
    }else{
      return SizedBox(width: max(_scrollWidth, consts.maxWidth),height: scrollBarSize,);
    }
  }




  @override
  void initState() {
    _resizingChangeNotifier = widget.stateManager.resizingChangeNotifier;
    _resizingChangeNotifier.addListener(_updateState);
    widget.scrollController.addListener(_onScroll);
    
    _calSize();
    super.initState();
  }

  void _updateState(){
    
    _calSize();
    setState(() {
    });
  }

  void _onScroll() {
    widget.scrollController.position.didUpdateScrollPositionBy(0);
  }
  

  void _calSize(){
      if(widget.direction == Axis.vertical){
        _scrollHeight = widget.stateManager.rowTotalHeight * widget.stateManager.refRows.length ;
      }else{
        List<PlutoColumn> scrollColumnList = widget.stateManager.refColumns.where((e){
          bool remove = e.hide;
          return !remove;
        }).toList();
        double width = 0;
        scrollColumnList.forEach((e) => width += e.width);
        _scrollWidth = width - widget.stateManager.bodyLeftOffset - widget.stateManager.bodyRightOffset;
      }
  }
  @override
  void dispose() {
    _resizingChangeNotifier.removeListener(_updateState);
    widget.stateManager.scroll.bodyRowsVertical!.removeListener(_onScroll);
    super.dispose();
  }

  @override
  PlutoGridStateManager get stateManager => widget.stateManager;

  @override
  void updateState(PlutoNotifierEvent event) {
    forceUpdate();

    _calSize();
  }
}
