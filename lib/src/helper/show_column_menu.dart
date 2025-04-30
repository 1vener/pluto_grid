import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pluto_grid/pluto_grid.dart';

abstract class PlutoColumnMenuDelegate<T> {
  List<PopupMenuEntry<T>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  });

  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required T? selected,
  });
}

abstract class PlutoColumnRightMenuDelegate {
  List<Widget> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required BuildContext context,
  });

}
class PlutoColumnRightMenuDelegateDefault
    implements PlutoColumnRightMenuDelegate {
  const PlutoColumnRightMenuDelegateDefault();

  @override
  List<Widget> buildMenuItems({required PlutoGridStateManager stateManager, required PlutoColumn column,required BuildContext context}) {
    final Color textColor = Theme.of(context).brightness == Brightness.light ? const Color.fromRGBO(0, 0, 0, 0.85) : const Color.fromRGBO(255, 255, 255, 0.85);

    final Color disableTextColor = textColor.withOpacity(0.5);

    final bool enoughFrozenColumnsWidth = stateManager.enoughFrozenColumnsWidth(
      stateManager.maxWidth! - column.width,
    );

    final localeText = stateManager.localeText;
    return [Padding(
      padding: EdgeInsets.all(6.0),
      child: Column(children: [
        if (column.frozen.isFrozen == true)
          _buildRightMenuItem(context:context, text: localeText.unfreezeColumn,textColor: textColor, onPressed: ()=>stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.none)),

        if (column.frozen.isFrozen != true) ...[
          _buildRightMenuItem(context:context,text:  localeText.freezeColumnToStart,textColor: textColor, onPressed: ()=>stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.start),enabled: enoughFrozenColumnsWidth),
          _buildRightMenuItem(context:context,text:  localeText.freezeColumnToEnd,textColor: textColor, onPressed: ()=>stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.end),enabled: enoughFrozenColumnsWidth),
        ],
        const Divider(),
        _buildRightMenuItem(context:context,text:  localeText.autoFitColumn,textColor: textColor, onPressed: (){
        stateManager.autoFitColumn(context, column);
        stateManager.notifyResizingListeners();}),
        if (column.enableHideColumnMenuItem == true)
          _buildRightMenuItem(context:context,text:  localeText.hideColumn, textColor: textColor,onPressed: ()=>stateManager.hideColumn(column, true),enabled: stateManager.refColumns.length > 1),

        if (column.enableSetColumnsMenuItem == true)
          _buildRightMenuItem(context:context,text:  localeText.setColumns,textColor: textColor, onPressed: ()=>stateManager.showSetColumnsPopup(context)),
        if (column.enableFilterMenuItem == true) ...[
          const Divider(),
          _buildRightMenuItem(context:context,text:  localeText.setFilter,textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor, onPressed: ()=>stateManager.showFilterPopup(context, calledColumn: column)),
          _buildRightMenuItem(context:context,text:  localeText.resetFilter,textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor, onPressed: ()=>stateManager.setFilter(null),enabled:  stateManager.hasFilter),
        ],
      ],),
    )
    ];
  }



}
class PlutoColumnMenuDelegateDefault
    implements PlutoColumnMenuDelegate<PlutoGridColumnMenuItem> {
  const PlutoColumnMenuDelegateDefault();

  @override
  List<PopupMenuEntry<PlutoGridColumnMenuItem>> buildMenuItems({
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
  }) {
    return _getDefaultColumnMenuItems(
      stateManager: stateManager,
      column: column,
    );
  }

  @override
  void onSelected({
    required BuildContext context,
    required PlutoGridStateManager stateManager,
    required PlutoColumn column,
    required bool mounted,
    required PlutoGridColumnMenuItem? selected,
  }) {
    switch (selected) {
      case PlutoGridColumnMenuItem.unfreeze:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.none);
        break;
      case PlutoGridColumnMenuItem.freezeToStart:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.start);
        break;
      case PlutoGridColumnMenuItem.freezeToEnd:
        stateManager.toggleFrozenColumn(column, PlutoColumnFrozen.end);
        break;
      case PlutoGridColumnMenuItem.autoFit:
        if (!mounted) return;
        stateManager.autoFitColumn(context, column);
        stateManager.notifyResizingListeners();
        break;
      case PlutoGridColumnMenuItem.hideColumn:
        stateManager.hideColumn(column, true);
        break;
      case PlutoGridColumnMenuItem.setColumns:
        if (!mounted) return;
        stateManager.showSetColumnsPopup(context);
        break;
      case PlutoGridColumnMenuItem.setFilter:
        if (!mounted) return;
        stateManager.showFilterPopup(context, calledColumn: column);
        break;
      case PlutoGridColumnMenuItem.resetFilter:
        stateManager.setFilter(null);
        break;
      default:
        break;
    }
  }
}

/// Open the context menu on the right side of the column.
Future<T?>? showColumnMenu<T>({
  required BuildContext context,
  required Offset position,
  required List<PopupMenuEntry<T>> items,
  Color backgroundColor = Colors.white,
}) {
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;

  return showMenu<T>(
    context: context,
    color: backgroundColor,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + overlay.size.width,
      position.dy + overlay.size.height,
    ),
    items: items,
    useRootNavigator: true,
  );
}

List<PopupMenuEntry<PlutoGridColumnMenuItem>> _getDefaultColumnMenuItems({
  required PlutoGridStateManager stateManager,
  required PlutoColumn column,
}) {
  final Color textColor = stateManager.style.cellTextStyle.color!;

  final Color disableTextColor = textColor.withOpacity(0.5);

  final bool enoughFrozenColumnsWidth = stateManager.enoughFrozenColumnsWidth(
    stateManager.maxWidth! - column.width,
  );

  final localeText = stateManager.localeText;

  return [
    if (column.frozen.isFrozen == true)
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.unfreeze,
        text: localeText.unfreezeColumn,
        textColor: textColor,
      ),
    if (column.frozen.isFrozen != true) ...[
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.freezeToStart,
        enabled: enoughFrozenColumnsWidth,
        text: localeText.freezeColumnToStart,
        textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor,
      ),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.freezeToEnd,
        enabled: enoughFrozenColumnsWidth,
        text: localeText.freezeColumnToEnd,
        textColor: enoughFrozenColumnsWidth ? textColor : disableTextColor,
      ),
    ],
    const PopupMenuDivider(),
    _buildMenuItem(
      value: PlutoGridColumnMenuItem.autoFit,
      text: localeText.autoFitColumn,
      textColor: textColor,
    ),
    if (column.enableHideColumnMenuItem == true)
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.hideColumn,
        text: localeText.hideColumn,
        textColor: textColor,
        enabled: stateManager.refColumns.length > 1,
      ),
    if (column.enableSetColumnsMenuItem == true)
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.setColumns,
        text: localeText.setColumns,
        textColor: textColor,
      ),
    if (column.enableFilterMenuItem == true) ...[
      const PopupMenuDivider(),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.setFilter,
        text: localeText.setFilter,
        textColor: textColor,
      ),
      _buildMenuItem(
        value: PlutoGridColumnMenuItem.resetFilter,
        text: localeText.resetFilter,
        textColor: textColor,
        enabled: stateManager.hasFilter,
      ),
    ],
  ];
}
Widget _buildRightMenuItem({
  required BuildContext context,
  required String text,
  required Color textColor,
  VoidCallback? onPressed,
  bool enabled = true,
}){
  return MenuItemButton(
    style: enabled ? null : Theme.of(context).menuButtonTheme.style?.copyWith(foregroundColor: WidgetStatePropertyAll(textColor.withOpacity(0.5))),
    onPressed: enabled ? onPressed : null,
    child: SizedBox(
      height: 24,
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
PopupMenuItem<PlutoGridColumnMenuItem> _buildMenuItem<PlutoGridColumnMenuItem>({
  required String text,
  required Color? textColor,
  bool enabled = true,
  PlutoGridColumnMenuItem? value,
}) {
  return PopupMenuItem<PlutoGridColumnMenuItem>(
    value: value,
    height: 36,
    enabled: enabled,
    child: Text(
      text,
      style: TextStyle(
        color: enabled ? textColor : textColor!.withOpacity(0.5),
        fontSize: 13,
      ),
    ),
  );
}

/// Items in the context menu on the right side of the column
enum PlutoGridColumnMenuItem {
  unfreeze,
  freezeToStart,
  freezeToEnd,
  hideColumn,
  setColumns,
  autoFit,
  setFilter,
  resetFilter,
}
