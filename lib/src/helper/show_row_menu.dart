import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoRowRightMenuDelegate {
  List<Widget> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required BuildContext context,
  });

}
class PlutoRowRightMenuDelegateDefault
    implements PlutoRowRightMenuDelegate {
  const PlutoRowRightMenuDelegateDefault();

  @override
  List<Widget> buildMenuItems({required PlutoGridStateManager stateManager,required BuildContext context}) {
    final Color textColor = stateManager.style.cellTextStyle.color!;

    return [Padding(
      padding: EdgeInsets.all(6.0),
      child: Column(children: [

          _buildRightMenuItem(context:context, text: 'Add Row',textColor: textColor, onPressed: ()=>handleAddRows(stateManager)),
          _buildRightMenuItem(context:context, text: 'Current Cell',textColor: textColor, onPressed: ()=>currentCell(stateManager)),

      ],),
    )
    ];
  }
  void handleAddRows(PlutoGridStateManager stateManager) {
    print('currentRow and current cell:${stateManager.currentCell?.column.field},${stateManager.currentRowIdx}');
    stateManager.appendNewRows(count: 1);

    stateManager.moveScrollByRow(
      PlutoMoveDirection.down,
      stateManager.refRows.length - 1,
    );
    stateManager.setCurrentCell(stateManager.refRows.last.cells[stateManager.refRows.last.cells.keys.first], stateManager.refRows.length - 1);
  }
  void currentCell(PlutoGridStateManager stateManager) {
    print('currentRow and current cell:${stateManager.currentCell?.column.field},${stateManager.currentRowIdx}');
  }
  Widget _buildRightMenuItem({
    required BuildContext context,
    required String text,
    required Color textColor,
    VoidCallback? onPressed,
    bool enabled = true,
  }){
    return MenuItemButton(
      style: Theme.of(context).menuButtonTheme.style?.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states){
          if (states.contains(WidgetState.hovered)) {
            return Theme.of(context).hoverColor;// 鼠标悬停时的颜色
          }
        }),
        foregroundColor: WidgetStateProperty.all(enabled ? textColor : textColor.withOpacity(0.5)),
      ),
      onPressed: enabled ? onPressed : null,
      child: SizedBox(
        height: 26,
        width: 120,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            strutStyle: const StrutStyle(
              fontSize: 11,
              leading: 0,
              height: 1.1,
              // 1.1更居中
              forceStrutHeight: true, // 关键属性 强制改为文字高度
            ),
            overflow: TextOverflow.ellipsis,
          ),),
      ),
    );
  }

}




/// Items in the context menu on the right side of the column
enum PlutoGridRowMenuItem {
  unfreeze,
  freezeToStart,
  freezeToEnd,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
}
