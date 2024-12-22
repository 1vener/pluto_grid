import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:pluto_grid/src/manager/pluto_grid_state_manager.dart';

class TableScrollbar extends StatefulWidget {
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

class _TableScrollbarState extends State<TableScrollbar> {
  late ChangeNotifier _resizingChangeNotifier;
   double _scrollWidth = 0;


  @override
  Widget build(BuildContext context) {
    double scrollBarSize = widget.stateManager.configuration.style.scrollBarSize;
    return
      LayoutBuilder(builder: (ctx,consts){
        print('const:{$consts}');
        return Container(
            decoration: BoxDecoration(color: Colors.transparent,),
            // padding: EdgeInsets.only(top: widget.direction == Axis.vertical ? 24 : 0,bottom: widget.direction == Axis.vertical ? 24 : 0),
            child: ScrollbarTheme(data: Theme.of(context).scrollbarTheme.copyWith(
                thumbVisibility: WidgetStatePropertyAll(true),
                trackVisibility: WidgetStatePropertyAll(true)
            ),
              child: ScrollbarTheme(
                data: widget.stateManager.configuration.scrollbarThemeData ?? Theme.of(ctx).scrollbarTheme,
                child: Scrollbar(
                  controller: widget.scrollController,
                  child: SingleChildScrollView(
                      controller: widget.scrollController,
                      scrollDirection: widget.direction,
                      child: _buildSizeBox(consts,scrollBarSize))),),));
      },);
  }

  Widget _buildSizeBox(BoxConstraints consts,double scrollBarSize){
    if(widget.direction == Axis.vertical){
      //widget.stateManager.rowTotalHeight * widget.stateManager.refRows.length
      //widget.stateManager.scroll.maxScrollVertical
      return SizedBox(
        width: scrollBarSize,height: max(widget.stateManager.rowTotalHeight * widget.stateManager.refRows.length, consts.maxHeight),);
    }else{
      print('maxWith:${max(_scrollWidth, consts.maxWidth)}');
      return SizedBox(width: max(_scrollWidth, consts.maxWidth),height: scrollBarSize,);
    }
  }




  @override
  void initState() {
    _resizingChangeNotifier = widget.stateManager.resizingChangeNotifier;
    _resizingChangeNotifier.addListener(_updateState);
    _calWidth();
    super.initState();
  }

  void _updateState(){
    _calWidth();
    setState(() {
    });
  }

  void _calWidth(){
    List<PlutoColumn> scrollColumnList = widget.stateManager.refColumns.where((e){
      bool remove = e.hide;
      return !remove;
    }).toList();
    double width = 0;
    scrollColumnList.forEach((e) => width += e.width);
    print('width---------{$width}');
    _scrollWidth = width;
  }
  @override
  void dispose() {
    _resizingChangeNotifier.removeListener(_updateState);
    super.dispose();
  }
}
