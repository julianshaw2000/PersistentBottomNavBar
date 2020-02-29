import 'dart:ui';

import 'package:flutter/material.dart';
import '../persistent-tab-view.dart';

class BottomNavStyle8 extends StatefulWidget {
  final int selectedIndex;
  final double iconSize;
  final Color backgroundColor;
  final bool showElevation;
  final Duration animationDuration;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;
  final double navBarHeight;
  final bool isIOS;
  final bool isCurved;
  final double bottomPadding;
  final double horizontalPadding;

  BottomNavStyle8(
      {Key key,
      this.selectedIndex,
      this.showElevation = false,
      this.iconSize,
      this.backgroundColor,
      this.animationDuration = const Duration(milliseconds: 1000),
      this.navBarHeight = 0.0,
      @required this.items,
      this.onItemSelected,
      this.bottomPadding,
      this.horizontalPadding,
      this.isCurved,
      this.isIOS = true});

  @override
  _BottomNavStyle8State createState() => _BottomNavStyle8State();
}

class _BottomNavStyle8State extends State<BottomNavStyle8>
    with TickerProviderStateMixin {
  List<AnimationController> _animationControllerList;
  List<Animation<double>> _animationList;

  int _lastSelectedIndex;
  int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _lastSelectedIndex = 0;
    _selectedIndex = 0;
    _animationControllerList = List<AnimationController>();
    _animationList = List<Animation<double>>();

    for (int i = 0; i < widget.items.length; ++i) {
      _animationControllerList.add(AnimationController(
          duration: Duration(milliseconds: 400), vsync: this));
      _animationList.add(Tween(begin: 0.95, end: 1.2)
          .chain(CurveTween(curve: Curves.ease))
          .animate(_animationControllerList[i]));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationControllerList[_selectedIndex].forward();
    });
  }

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected,
      double height, int itemIndex) {
    return Container(
      width: 150.0,
      height: widget.isIOS ? height / 1.8 : height,
      child: Container(
        alignment: Alignment.center,
        height: widget.isIOS ? height / 1.8 : height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: IconTheme(
                data: IconThemeData(
                    size: widget.iconSize,
                    color: isSelected
                        ? (item.activeContentColor == null
                            ? item.activeColor
                            : item.activeContentColor)
                        : item.inactiveColor == null
                            ? item.activeColor
                            : item.inactiveColor),
                child: item.icon,
              ),
            ),
            AnimatedBuilder(
              animation: _animationList[itemIndex],
              builder: (context, child) => Transform.scale(
                scale: _animationList[itemIndex].value,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Material(
                    type: MaterialType.transparency,
                    child: FittedBox(
                      child: Text(
                        item.title,
                        style: TextStyle(
                            color: isSelected
                                ? (item.activeContentColor == null
                                    ? item.activeColor
                                    : item.activeContentColor)
                                : item.inactiveColor,
                            fontWeight: FontWeight.w400,
                            fontSize: item.titleFontSize),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  bool opaque() {
    for (int i = 0; i < widget.items.length; ++i) {
      if (widget.items[i].isTranslucent) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: getNavBarDecoration(
        isCurved: widget.isCurved,
        showElevation: widget.showElevation,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.isCurved ? 15.0 : 0.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
          child: Container(
            color: getBackgroundColor(context, widget.items,
                widget.backgroundColor, widget.selectedIndex),
            child: Container(
              width: double.infinity,
              height: widget.navBarHeight,
              padding: widget.isIOS
                  ? EdgeInsets.only(
                      left: widget.horizontalPadding == null
                          ? MediaQuery.of(context).size.width * 0.04
                          : widget.horizontalPadding,
                      right: widget.horizontalPadding == null
                          ? MediaQuery.of(context).size.width * 0.04
                          : widget.horizontalPadding,
                      top: widget.navBarHeight * 0.12,
                      bottom: widget.bottomPadding == null
                          ? widget.navBarHeight * 0.36
                          : widget.bottomPadding)
                  : EdgeInsets.only(
                      left: widget.horizontalPadding == null
                          ? MediaQuery.of(context).size.width * 0.04
                          : widget.horizontalPadding,
                      right: widget.horizontalPadding == null
                          ? MediaQuery.of(context).size.width * 0.04
                          : widget.horizontalPadding,
                      top: widget.navBarHeight * 0.15,
                      bottom: widget.bottomPadding == null
                          ? widget.navBarHeight * 0.12
                          : widget.bottomPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: widget.isIOS
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: widget.items.map((item) {
                  var index = widget.items.indexOf(item);
                  return Flexible(
                    child: GestureDetector(
                      onTap: () {
                        _lastSelectedIndex = _selectedIndex;
                        _selectedIndex = index;
                        _animationControllerList[_selectedIndex].forward();
                        _animationControllerList[_lastSelectedIndex].reverse();
                        widget.onItemSelected(index);
                      },
                      child: _buildItem(item, widget.selectedIndex == index,
                          widget.navBarHeight, index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
