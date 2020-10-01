/// Drag and drop list reordering for two level lists.
///
/// [DragAndDropLists] is the main widget, and contains numerous options for controlling overall list presentation.
///
/// The children of [DragAndDropLists] are [DragAndDropList] or another class that inherits from
/// [DragAndDropListInterface] such as [DragAndDropListExpansion]. These lists can be reordered at will.
/// Each list contains its own properties, and can be styled separately if the defaults provided to [DragAndDropLists]
/// should be overridden.
///
/// The children of a [DragAndDropListInterface] are [DragAndDropItem]. These are the individual elements and can be
/// reordered within their own list and into other lists. If they should not be able to be reordered, they can also
/// be locked individually.
library drag_and_drop_lists;

import 'dart:math';

import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

export 'package:drag_and_drop_lists/drag_and_drop_item.dart';
export 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
export 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list_expansion.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list_target.dart';
export 'package:drag_and_drop_lists/drag_and_drop_list_wrapper.dart';

class DragAndDropLists extends StatefulWidget {
  /// The child lists to be displayed.
  /// If any of these children are [DragAndDropListExpansion] or inherit from
  /// [DragAndDropListExpansionInterface], [listGhost] must not be null.
  final List<DragAndDropListInterface> children;

  /// Calls this function when a list element is reordered.
  /// Takes into account the index change when removing an item, so the
  /// [newItemIndex] can be used directly when inserting.
  final Function(int oldItemIndex, int oldListIndex, int newItemIndex,
      int newListIndex) onItemReorder;

  /// Calls this function when a list is reordered.
  /// Takes into account the index change when removing a list, so the
  /// [newListIndex] can be used directly when inserting.
  final Function(int oldListIndex, int newListIndex) onListReorder;

  /// Calls this function when a new item has been added.
  final Function(DragAndDropItem newItem, int listIndex, int newItemIndex)
      onItemAdd;

  /// Calls this function when a new list has been added.
  final Function(DragAndDropListInterface newList, int newListIndex) onListAdd;

  /// Width of a list item when it is being dragged.
  final double itemDraggingWidth;

  /// The widget that will be displayed at a potential drop position in a list
  /// when an item is being dragged.
  final Widget itemGhost;

  /// The opacity of the [itemGhost]. This must be between 0 and 1.
  final double itemGhostOpacity;

  /// Length of animation for the change in an item size when displaying the [itemGhost].
  final int itemSizeAnimationDurationMilliseconds;

  /// If true, drag an item after doing a long press. If false, drag immediately.
  final bool itemDragOnLongPress;

  /// The decoration surrounding an item.
  final Decoration itemDecoration;

  /// A widget that will be displayed between each individual item.
  final Widget itemDivider;

  /// The width of a list when dragging.
  final double listDraggingWidth;

  /// The widget to be displayed as the last element in the DragAndDropLists,
  /// where a list will be accepted as the last list.
  final Widget listTarget;

  /// The widget to be displayed at a potential list position while a list is being dragged.
  /// This must not be null when [children] includes one or more
  /// [DragAndDropListExpansion] or other class that inherit from [DragAndDropListExpansionInterface].
  final Widget listGhost;

  /// The opacity of [listGhost]. It must be between 0 and 1.
  final double listGhostOpacity;

  /// The duration of the animation for the change in size when a [listGhost] is
  /// displayed at list position.
  final int listSizeAnimationDurationMilliseconds;

  /// Whether a list should be dragged on a long or short press.
  /// When true, the list will be dragged after a long press.
  /// When false, it will be dragged immediately.
  final bool listDragOnLongPress;

  /// The decoration surrounding a list.
  final Decoration listDecoration;

  /// The decoration surrounding the inner list of items.
  final Decoration listInnerDecoration;

  /// A widget that will be displayed between each individual list.
  final Widget listDivider;

  /// The padding between each individual list.
  final EdgeInsets listPadding;

  /// A widget that will be displayed whenever a list contains no items.
  final Widget contentsWhenEmpty;

  /// The width of each individual list. This must be set to a finite value when
  /// [axis] is set to Axis.horizontal.
  final double listWidth;

  /// The height of the target for the last item in a list. This should be large
  /// enough to easily drag an item into the last position of a list.
  final double lastItemTargetHeight;

  /// Add the same height as the lastItemTargetHeight to the top of the list.
  /// This is useful when setting the [listInnerDecoration] to maintain visual
  /// continuity between the top and the bottom
  final bool addLastItemTargetHeightToTop;

  /// The height of the target for the last list. This should be large
  /// enough to easily drag a list to the last position in the DragAndDropLists.
  final double lastListTargetSize;

  /// The default vertical alignment of list contents.
  final CrossAxisAlignment verticalAlignment;

  /// The default horizontal alignment of list contents.
  final MainAxisAlignment horizontalAlignment;

  /// Determines whether the DragAndDropLists are displayed in a horizontal or
  /// vertical manner.
  /// Set [axis] to Axis.vertical for vertical arrangement of the lists.
  /// Set [axis] to Axis.horizontal for horizontal arrangement of the lists.
  /// If [axis] is set to Axis.horizontal, [listWidth] must be set to some finite number.
  final Axis axis;

  /// Whether or not to return a widget or a sliver-compatible list.
  /// Set to true if using as a sliver. If true, a [scrollController] must be provided.
  /// Set to false if using in a widget only.
  final bool sliverList;

  /// A scroll controller that can be used for the scrolling of the first level lists.
  /// This must be set if [sliverList] is set to true.
  final ScrollController scrollController;

  /// Set a custom drag handle to use iOS-like handles to drag rather than long
  /// or short presses
  final Widget dragHandle;

  DragAndDropLists({
    this.children,
    this.onItemReorder,
    this.onListReorder,
    this.onItemAdd,
    this.onListAdd,
    this.itemDraggingWidth,
    this.itemGhost,
    this.itemGhostOpacity = 0.3,
    this.itemSizeAnimationDurationMilliseconds = 150,
    this.itemDragOnLongPress = true,
    this.itemDecoration,
    this.itemDivider,
    this.listDraggingWidth,
    this.listTarget,
    this.listGhost,
    this.listGhostOpacity = 0.3,
    this.listSizeAnimationDurationMilliseconds = 150,
    this.listDragOnLongPress = true,
    this.listDecoration,
    this.listInnerDecoration,
    this.listDivider,
    this.listPadding,
    this.contentsWhenEmpty,
    this.listWidth = double.infinity,
    this.lastItemTargetHeight = 20,
    this.addLastItemTargetHeightToTop = false,
    this.lastListTargetSize = 110,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.horizontalAlignment = MainAxisAlignment.start,
    this.axis = Axis.vertical,
    this.sliverList = false,
    this.scrollController,
    this.dragHandle,
    Key key,
  }) : super(key: key) {
    if (listGhost == null &&
        children
            .where((element) => element is DragAndDropListExpansionInterface)
            .isNotEmpty)
      throw Exception(
          'If using DragAndDropListExpansion, you must provide a non-null listGhost');
    if (sliverList && scrollController == null) {
      throw Exception(
          'A scroll controller must be provided when using sliver lists');
    }
    if (axis == Axis.horizontal && listWidth == double.infinity) {
      throw Exception(
          'A finite width must be provided when setting the axis to horizontal');
    }
    if (axis == Axis.horizontal && sliverList) {
      throw Exception(
          'Combining a sliver list with a horizontal list is currently unsupported');
    }
  }

  @override
  State<StatefulWidget> createState() => DragAndDropListsState();
}

class DragAndDropListsState extends State<DragAndDropLists> {
  ScrollController _scrollController;
  bool _pointerDown = false;
  double _pointerYPosition;
  double _pointerXPosition;
  bool _scrolling = false;
  PageStorageBucket _pageStorageBucket = PageStorageBucket();

  @override
  void initState() {
    if (widget.scrollController != null)
      _scrollController = widget.scrollController;
    else
      _scrollController = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var parameters = DragAndDropBuilderParameters(
      listGhost: widget.listGhost,
      listGhostOpacity: widget.listGhostOpacity,
      draggingWidth: widget.listDraggingWidth,
      listSizeAnimationDuration: widget.listSizeAnimationDurationMilliseconds,
      dragOnLongPress: widget.listDragOnLongPress,
      listPadding: widget.listPadding,
      itemSizeAnimationDuration: widget.itemSizeAnimationDurationMilliseconds,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerMove: _onPointerMove,
      onItemReordered: _internalOnItemReorder,
      onItemDropOnLastTarget: _internalOnItemDropOnLastTarget,
      onListReordered: _internalOnListReorder,
      itemGhostOpacity: widget.itemGhostOpacity,
      itemDivider: widget.itemDivider,
      verticalAlignment: widget.verticalAlignment,
      axis: widget.axis,
      itemGhost: widget.itemGhost,
      listDecoration: widget.listDecoration,
      listInnerDecoration: widget.listInnerDecoration,
      listWidth: widget.listWidth,
      lastItemTargetHeight: widget.lastItemTargetHeight,
      addLastItemTargetHeightToTop: widget.addLastItemTargetHeightToTop,
      dragHandle: widget.dragHandle,
    );

    DragAndDropListTarget dragAndDropListTarget = DragAndDropListTarget(
      child: widget.listTarget,
      parameters: parameters,
      onDropOnLastTarget: _internalOnListDropOnLastTarget,
      lastListTargetSize: widget.lastListTargetSize,
    );

    if (widget.children != null && widget.children.isNotEmpty) {
      Widget listView;

      if (widget.sliverList) {
        int childrenCount;
        bool includeSeparators = widget.listDivider != null;
        if (includeSeparators)
          childrenCount = (widget.children?.length ?? 0) * 2;
        else
          childrenCount = (widget.children?.length ?? 0) + 1;
        listView = SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == childrenCount - 1) {
                return dragAndDropListTarget;
              } else if (includeSeparators && index.isOdd) {
                return widget.listDivider;
              } else {
                return DragAndDropListWrapper(
                  dragAndDropList: widget.children[index],
                  parameters: parameters,
                );
              }
            },
            childCount: childrenCount,
          ),
        );
      } else {
        if (widget.listDivider != null) {
          listView = ListView.separated(
            scrollDirection: widget.axis,
            controller: _scrollController,
            separatorBuilder: (_, index) => widget.listDivider,
            itemCount: (widget.children?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index < (widget.children?.length ?? 0)) {
                return DragAndDropListWrapper(
                  dragAndDropList: widget.children[index],
                  parameters: parameters,
                );
              } else {
                return dragAndDropListTarget;
              }
            },
          );
        } else {
          listView = ListView.builder(
            scrollDirection: widget.axis,
            controller: _scrollController,
            itemCount: (widget.children?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index < (widget.children?.length ?? 0)) {
                return DragAndDropListWrapper(
                  dragAndDropList: widget.children[index],
                  parameters: parameters,
                );
              } else {
                return dragAndDropListTarget;
              }
            },
          );
        }
      }

      if (widget.children
          .where((e) => e is DragAndDropListExpansionInterface)
          .isNotEmpty) {
        listView = PageStorage(
          child: listView,
          bucket: _pageStorageBucket,
        );
      }
      return listView;
    } else {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            widget.contentsWhenEmpty ?? Text('Empty'),
            dragAndDropListTarget,
          ],
        ),
      );
    }
  }

  _internalOnItemReorder(DragAndDropItem reordered, DragAndDropItem receiver) {
    int reorderedListIndex = -1;
    int reorderedItemIndex = -1;
    int receiverListIndex = -1;
    int receiverItemIndex = -1;

    for (int i = 0; i < widget.children.length; i++) {
      if (reorderedItemIndex == -1) {
        reorderedItemIndex =
            widget.children[i].children.indexWhere((e) => reordered == e);
        if (reorderedItemIndex != -1) reorderedListIndex = i;
      }
      if (receiverItemIndex == -1) {
        receiverItemIndex =
            widget.children[i].children.indexWhere((e) => receiver == e);
        if (receiverItemIndex != -1) receiverListIndex = i;
      }
      if (reorderedItemIndex != -1 && receiverItemIndex != -1) {
        break;
      }
    }

    if (reorderedItemIndex == -1) {
      // this is a new item
      if (widget.onItemAdd != null)
        widget.onItemAdd(reordered, receiverListIndex, receiverItemIndex);
    } else {
      if (reorderedListIndex == receiverListIndex &&
          receiverItemIndex > reorderedItemIndex) {
        // same list, so if the new position is after the old position, the removal of the old item must be taken into account
        receiverItemIndex--;
      }

      if (widget.onItemReorder != null)
        widget.onItemReorder(reorderedItemIndex, reorderedListIndex,
            receiverItemIndex, receiverListIndex);
    }
  }

  _internalOnListReorder(
      DragAndDropListInterface reordered, DragAndDropListInterface receiver) {
    int reorderedListIndex = widget.children.indexWhere((e) => reordered == e);
    int receiverListIndex = widget.children.indexWhere((e) => receiver == e);

    int newListIndex = receiverListIndex;

    if (reorderedListIndex == -1) {
      // this is a new list
      if (widget.onListAdd != null) widget.onListAdd(reordered, newListIndex);
    } else {
      if (newListIndex > reorderedListIndex) {
        // same list, so if the new position is after the old position, the removal of the old item must be taken into account
        newListIndex--;
      }
      if (widget.onListReorder != null)
        widget.onListReorder(reorderedListIndex, newListIndex);
    }
  }

  _internalOnItemDropOnLastTarget(DragAndDropItem newOrReordered,
      DragAndDropListInterface parentList, DragAndDropItemTarget receiver) {
    int reorderedListIndex = -1;
    int reorderedItemIndex = -1;
    int receiverListIndex = -1;
    int receiverItemIndex = -1;

    if (widget.children != null && widget.children.isNotEmpty) {
      for (int i = 0; i < widget.children.length; i++) {
        if (reorderedItemIndex == -1) {
          reorderedItemIndex = widget.children[i].children
                  ?.indexWhere((e) => newOrReordered == e) ??
              -1;
          if (reorderedItemIndex != -1) reorderedListIndex = i;
        }

        if (receiverItemIndex == -1 && widget.children[i] == parentList) {
          receiverListIndex = i;
          receiverItemIndex = widget.children[i].children?.length ?? -1;
        }

        if (reorderedItemIndex != -1 && receiverItemIndex != -1) {
          break;
        }
      }
    }

    if (reorderedItemIndex == -1) {
      if (widget.onItemAdd != null)
        widget.onItemAdd(newOrReordered, receiverListIndex, reorderedItemIndex);
    } else {
      if (reorderedListIndex == receiverListIndex &&
          receiverItemIndex > reorderedItemIndex) {
        // same list, so if the new position is after the old position, the removal of the old item must be taken into account
        receiverItemIndex--;
      }
      if (widget.onItemReorder != null)
        widget.onItemReorder(reorderedItemIndex, reorderedListIndex,
            receiverItemIndex, receiverListIndex);
    }
  }

  _internalOnListDropOnLastTarget(
      DragAndDropListInterface newOrReordered, DragAndDropListTarget receiver) {
    // determine if newOrReordered is new or existing
    int reorderedListIndex =
        widget.children.indexWhere((e) => newOrReordered == e);
    if (reorderedListIndex >= 0) {
      if (widget.onListReorder != null)
        widget.onListReorder(reorderedListIndex, widget.children.length - 1);
    } else {
      if (widget.onListAdd != null)
        widget.onListAdd(newOrReordered, reorderedListIndex);
    }
  }

  _onPointerMove(PointerMoveEvent event) {
    if (_pointerDown) {
      _pointerYPosition = event.position.dy;
      _pointerXPosition = event.position.dx;

      _scrollList();
    }
  }

  _onPointerDown(PointerDownEvent event) {
    _pointerDown = true;
    _pointerYPosition = event.position.dy;
    _pointerXPosition = event.position.dx;
  }

  _onPointerUp(PointerUpEvent event) {
    _pointerDown = false;
  }

  _scrollList() async {
    if (!_scrolling &&
        _pointerDown &&
        _pointerYPosition != null &&
        _pointerXPosition != null) {
      int duration = 30; // in ms
      int scrollAreaSize = 20;
      double step = 1.5;
      double overDragMax = 20.0;
      double overDragCoefficient = 5.0;
      double newOffset;

      var rb = context.findRenderObject();
      Size size;
      if (rb is RenderBox)
        size = rb.size;
      else if (rb is RenderSliver) size = rb.paintBounds.size;
      var topLeftOffset = localToGlobal(rb, Offset.zero);
      var bottomRightOffset = localToGlobal(rb, size.bottomRight(Offset.zero));

      if (widget.axis == Axis.vertical) {
        double top = topLeftOffset.dy;
        double bottom = bottomRightOffset.dy;

        if (_pointerYPosition < (top + scrollAreaSize) &&
            _scrollController.position.pixels >
                _scrollController.position.minScrollExtent) {
          final overDrag =
              max((top + scrollAreaSize) - _pointerYPosition, overDragMax);
          newOffset = max(
              _scrollController.position.minScrollExtent,
              _scrollController.position.pixels -
                  step * overDrag / overDragCoefficient);
        } else if (_pointerYPosition > (bottom - scrollAreaSize) &&
            _scrollController.position.pixels <
                _scrollController.position.maxScrollExtent) {
          final overDrag = max<double>(
              _pointerYPosition - (bottom - scrollAreaSize), overDragMax);
          newOffset = min(
              _scrollController.position.maxScrollExtent,
              _scrollController.position.pixels +
                  step * overDrag / overDragCoefficient);
        }
      } else {
        double left = topLeftOffset.dx;
        double right = bottomRightOffset.dx;

        if (_pointerXPosition < (left + scrollAreaSize) &&
            _scrollController.position.pixels >
                _scrollController.position.minScrollExtent) {
          final overDrag =
              max((left + scrollAreaSize) - _pointerXPosition, overDragMax);
          newOffset = max(
              _scrollController.position.minScrollExtent,
              _scrollController.position.pixels -
                  step * overDrag / overDragCoefficient);
        } else if (_pointerXPosition > (right - scrollAreaSize) &&
            _scrollController.position.pixels <
                _scrollController.position.maxScrollExtent) {
          final overDrag = max<double>(
              _pointerYPosition - (right - scrollAreaSize), overDragMax);
          newOffset = min(
              _scrollController.position.maxScrollExtent,
              _scrollController.position.pixels +
                  step * overDrag / overDragCoefficient);
        }
      }

      if (newOffset != null) {
        _scrolling = true;
        await _scrollController.animateTo(newOffset,
            duration: Duration(milliseconds: duration), curve: Curves.linear);
        _scrolling = false;
        if (_pointerDown) _scrollList();
      }
    }
  }

  static Offset localToGlobal(RenderObject object, Offset point,
      {RenderObject ancestor}) {
    return MatrixUtils.transformPoint(object.getTransformTo(ancestor), point);
  }
}
