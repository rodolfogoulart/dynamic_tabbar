// Copyright (c) 2023 Ali Haider. All rights reserved.
// Use of this source code is governed by MIT License that can be
// found in the LICENSE file.

library dynamic_tabbar;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TabData {
  final int index;
  final Tab title;
  final Widget content;

  TabData({required this.index, required this.title, required this.content});
}

/// Defines where the Tab indicator animation moves to when new Tab is added.
///
///
enum MoveToTab {
  /// The [idol] indicator will remain on current Tab when new Tab is added.
  idol,
  // next,
  // previous,
  // first,
  /// The [last] indicator will move to the Last Tab when new Tab is added.
  last,
}

///Alignment of the vertical Tab
enum AlignmentVertical {
  top,
  center,
  bottom;

  const AlignmentVertical();

  get value {
    return (index - 1).toDouble();
  }
}

/// Dynamic Tabs.
class DynamicTabBarWidget extends TabBar {
  /// List of Tabs.
  ///
  /// TabData contains [index] of the tab and the title which is extension of [TabBar] header.
  /// and the [content] is the extension of [TabBarView] so all the page content is displayed in this section
  ///
  ///
  final List<TabData> dynamicTabs;
  final Function(TabController) onTabControllerUpdated;
  final Function(int?)? onTabChanged;

  /// Defines where the Tab indicator animation moves to when new Tab is added.
  ///
  /// TabData contains two states at the moment [IDOL] and [LAST]
  ///
  final MoveToTab? onAddTabMoveTo;

  /// The back icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default back icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? backIcon;

  /// The forward icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default forward icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? nextIcon;

  /// The showBackIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showBackIcon;

  /// The showNextIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showNextIcon;

  /// The leading property is used to add custom leading widget in TabBar.
  ///
  /// By default [leading] widget is null.
  ///
  final Widget? leading;

  /// The leading property is used to add custom trailing widget in TabBar.
  ///
  /// By default [trailing] widget is null.
  ///
  final Widget? trailing;

  /// The physics property is used to set the physics of TabBarView.
  final ScrollPhysics? physicsTabBarView;

  /// The dragStartBehavior property is used to set the dragStartBehavior of TabBarView.
  ///
  /// By default [dragStartBehavior] is DragStartBehavior.start.
  final DragStartBehavior dragStartBehaviorTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final double viewportFractionTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final Clip clipBehaviorTabBarView;

  /// Custom Builder Widget for the Tab
  final Widget Function(Widget widget)? customBuilderTab;

  /// Custom builder Widget for the tabView
  final Widget Function(Widget widget)? customBuilderTabView;

  /// Set the tab on Vertical or Horizontal
  ///
  /// default value = Horizontal
  ///
  /// When Vertical, it will use the NavigationRail, so most of the custom properties of the Tab will not work only the basic
  final Axis? axisTab;

  /// Direction of the Tab
  ///
  /// can be used on both, vertical of horizontal tab
  ///
  /// up, left, right, down
  final AxisDirection? axisDirectionTab;

  /// only used when axisTab = Axis.vertical
  ///
  /// Alignment of the vertical Tab
  final AlignmentVertical? alignmentVertical;

  DynamicTabBarWidget({
    super.key,
    required this.dynamicTabs,
    required this.onTabControllerUpdated,
    this.onTabChanged,
    this.onAddTabMoveTo,
    super.isScrollable,
    this.backIcon,
    this.nextIcon,
    this.showBackIcon = true,
    this.showNextIcon = true,
    this.leading,
    this.trailing,
    // Default Tab properties :---------------------------------------
    super.padding,
    super.indicatorColor,
    super.automaticIndicatorColorAdjustment = true,
    super.indicatorWeight = 2.0,
    super.indicatorPadding = EdgeInsets.zero,
    super.indicator,
    super.indicatorSize,
    super.dividerColor,
    super.dividerHeight,
    super.labelColor,
    super.labelStyle,
    super.labelPadding,
    super.unselectedLabelColor,
    super.unselectedLabelStyle,
    super.dragStartBehavior = DragStartBehavior.start,
    super.overlayColor,
    super.mouseCursor,
    super.enableFeedback,
    super.onTap,
    super.physics,
    super.splashFactory,
    super.splashBorderRadius,
    super.tabAlignment,
    // Default TabBarView properties :---------------------------------------
    this.physicsTabBarView,
    this.dragStartBehaviorTabBarView = DragStartBehavior.start,
    this.viewportFractionTabBarView = 1.0,
    this.clipBehaviorTabBarView = Clip.hardEdge,
    // Custom builder
    this.customBuilderTab,
    this.customBuilderTabView,
    this.axisTab,
    this.axisDirectionTab,
    this.alignmentVertical,
  }) : super(tabs: []);

  @override
  // ignore: library_private_types_in_public_api
  _DynamicTabBarWidgetState createState() => _DynamicTabBarWidgetState();
}

class _DynamicTabBarWidgetState extends State<DynamicTabBarWidget> with TickerProviderStateMixin {
  // Tab Controller
  TabController? _tabController;

  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = getTabController(initialIndex: activeTab);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _tabController = getTabController(initialIndex: widget.dynamicTabs.length - 1);
    widget.onTabControllerUpdated(_tabController = getTabController());
  }

  @override
  void didUpdateWidget(covariant DynamicTabBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_tabController?.length != widget.dynamicTabs.length) {
      var activeTabIndex = getActiveTab();
      if (activeTabIndex >= widget.dynamicTabs.length) {
        activeTabIndex = widget.dynamicTabs.length - 1;
      }
      _tabController = getTabController(initialIndex: activeTabIndex);

      var tabIndex = getOnAddMoveToTab(widget.onAddTabMoveTo);
      if (tabIndex != null) {
        Future.delayed(const Duration(milliseconds: 50), () {
          _tabController?.animateTo(
            tabIndex,
          );
          setState(() {
            activeTab = tabIndex;
          });
        });
      }
    } else {
      // debugPrint('NOOOOO Tab controller updated');
    }
  }

  TabController getTabController({int initialIndex = 0}) {
    if (initialIndex >= widget.dynamicTabs.length) {
      initialIndex = widget.dynamicTabs.length - 1;
    }
    return TabController(
      initialIndex: initialIndex,
      length: widget.dynamicTabs.length,
      vsync: this,
    )..addListener(() {
        setState(() {
          activeTab = _tabController?.index ?? 0;
          if (_tabController?.indexIsChanging == true) {
            widget.onTabChanged!(_tabController?.index);
          }
        });
      });
  }

  int getActiveTab() {
    // when there are No tabs
    if (activeTab == 0 && widget.dynamicTabs.isEmpty) {
      return 0;
    }
    if (activeTab == widget.dynamicTabs.length) {
      return widget.dynamicTabs.length - 1;
    }
    if (activeTab < widget.dynamicTabs.length) {
      return activeTab;
    }
    return widget.dynamicTabs.length;
  }

  // ignore: body_might_complete_normally_nullable
  int? getOnAddMoveToTab(MoveToTab? moveToTab) {
    switch (moveToTab) {
      // case MoveToTab.NEXT:
      //   return widget.dynamicTabs.length - 1;

      // case MoveToTab.PREVIOUS:
      //   return widget.dynamicTabs.length - 2;

      // case MoveToTab.FIRST:
      //   return 1;

      case MoveToTab.last:
        return widget.dynamicTabs.length - 1;

      case MoveToTab.idol:
        return null;

      case null:
        // move to Last Tab
        return widget.dynamicTabs.length - 1;
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  final ValueNotifier selectedIndex = ValueNotifier(0);
  @override
  Widget build(BuildContext context) {
    List<Widget> childrenTab = [
      if (widget.leading != null) widget.leading!,
      if (widget.isScrollable == true && widget.showBackIcon == true)
        IconButton(
          icon: widget.backIcon ??
              Icon(
                widget.axisTab == Axis.vertical ? Icons.keyboard_arrow_up : Icons.arrow_back_ios,
              ),
          onPressed: _moveToPreviousTab,
        ),
      Expanded(
        child: widget.axisTab == Axis.vertical
            ? ValueListenableBuilder(
                valueListenable: selectedIndex,
                builder: (context, value, child) {
                  return LayoutBuilder(builder: (context, constraint) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraint.maxHeight),
                        child: IntrinsicHeight(
                          child: NavigationRail(
                            destinations: widget.dynamicTabs.map((tab) {
                              return NavigationRailDestination(
                                icon: tab.title.icon ?? tab.title.child ?? Text(tab.title.text ?? ''),
                                label: Text(tab.title.text ?? ''),
                              );
                            }).toList(),
                            onDestinationSelected: (value) {
                              _tabController = getTabController(initialIndex: value);
                              _tabController?.animateTo(value);
                              selectedIndex.value = value;
                              widget.onTap?.call(value);
                              setState(() {
                                activeTab = value;
                                if (_tabController?.indexIsChanging == true) {
                                  widget.onTabChanged!(_tabController?.index);
                                }
                              });
                            },
                            selectedIndex: selectedIndex.value,
                            indicatorColor: widget.indicatorColor,
                            useIndicator: true,
                            groupAlignment: widget.alignmentVertical?.value ?? AlignmentVertical.top.value,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  });
                })
            : TabBar(
                isScrollable: widget.isScrollable,
                controller: _tabController,
                tabs: widget.dynamicTabs.map((tab) => tab.title).toList(),
                // Default Tab properties :---------------------------------------
                padding: widget.padding,
                indicatorColor: widget.indicatorColor,
                automaticIndicatorColorAdjustment: widget.automaticIndicatorColorAdjustment,
                indicatorWeight: widget.indicatorWeight,
                indicatorPadding: widget.indicatorPadding,
                indicator: widget.indicator,
                indicatorSize: widget.indicatorSize,
                dividerColor: widget.dividerColor,
                dividerHeight: widget.dividerHeight,
                labelColor: widget.labelColor,
                labelStyle: widget.labelStyle,
                labelPadding: widget.labelPadding,
                unselectedLabelColor: widget.unselectedLabelColor,
                unselectedLabelStyle: widget.unselectedLabelStyle,
                dragStartBehavior: widget.dragStartBehavior,
                overlayColor: widget.overlayColor,
                mouseCursor: widget.mouseCursor,
                enableFeedback: widget.enableFeedback,
                onTap: widget.onTap,
                physics: widget.physics,
                splashFactory: widget.splashFactory,
                splashBorderRadius: widget.splashBorderRadius,
                tabAlignment: widget.tabAlignment,
              ),
      ),
      if (widget.isScrollable == true && widget.showNextIcon == true)
        IconButton(
          icon: widget.nextIcon ??
              Icon(
                widget.axisTab == Axis.vertical ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios,
              ),
          onPressed: _moveToNextTab,
        ),
      if (widget.trailing != null) widget.trailing!,
    ];
    //
    Widget tabBar = widget.axisTab == Axis.vertical
        ? Column(children: childrenTab)
        : Row(mainAxisSize: MainAxisSize.min, children: childrenTab);
    //
    Widget tabView = TabBarView(
      controller: _tabController,
      physics: widget.physicsTabBarView,
      dragStartBehavior: widget.dragStartBehaviorTabBarView,
      viewportFraction: widget.viewportFractionTabBarView,
      clipBehavior: widget.clipBehaviorTabBarView,
      children: widget.dynamicTabs.map((tab) => tab.content).toList(),
    );
    // _tabController = getTabController(initialIndex: widget.dynamicTabs.length - 1);

    Widget child;
    if (widget.axisTab == Axis.vertical) {
      child = Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          //custom render the tab on left
          if (widget.axisDirectionTab == AxisDirection.left) widget.customBuilderTab?.call(tabBar) ?? tabBar,
          Expanded(child: widget.customBuilderTabView?.call(tabView) ?? tabView),
          //normal render the tab on right
          if (widget.axisDirectionTab != AxisDirection.left) widget.customBuilderTab?.call(tabBar) ?? tabBar,
        ],
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // normal render the tab on top
          if (widget.axisDirectionTab != AxisDirection.down) widget.customBuilderTab?.call(tabBar) ?? tabBar,
          Expanded(child: widget.customBuilderTabView?.call(tabView) ?? tabView),
          //if want to render the tab on bottom
          if (widget.axisDirectionTab == AxisDirection.down) widget.customBuilderTab?.call(tabBar) ?? tabBar,
        ],
      );
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: DefaultTabController(
        length: widget.dynamicTabs.length,
        child: child,
      ),
    );
  }

  _moveToNextTab() {
    if (_tabController != null && _tabController!.index + 1 < _tabController!.length) {
      _tabController!.animateTo(_tabController!.index + 1);
      selectedIndex.value = _tabController?.index;
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't move forward"),
      // ));
    }
  }

  _moveToPreviousTab() {
    if (_tabController != null && _tabController!.index > 0) {
      _tabController!.animateTo(_tabController!.index - 1);
      selectedIndex.value = _tabController?.index;
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't go back"),
      // ));
    }
  }
}
