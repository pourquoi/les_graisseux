

import 'package:flutter/material.dart';

class ItemFader extends StatefulWidget {
  final Widget child;
  final int itemIndex;
  final int itemCount;

  const ItemFader({Key key, @required this.child, @required this.itemIndex, @required this.itemCount}) : super(key: key);

  @override
  ItemFaderState createState() => ItemFaderState();
}

class ItemFaderState extends State<ItemFader>
    with SingleTickerProviderStateMixin {
  // 1 means its below, -1 means its above
  int position = 1;
  AnimationController _animationController;
  Animation _animation;
  final _animationDelay = 200;
  final _animationDuration = 400;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _animationDuration),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    show();
  }

  Future<void> show() async {
    await Future.delayed(Duration(milliseconds: widget.itemIndex*_animationDelay));
    setState(() => position = 1);
    _animationController.forward();
  }

  Future<void> hide() async {
    await Future.delayed(Duration(milliseconds: (widget.itemCount - widget.itemIndex)*_animationDelay));
    setState(() => position = -1);
    _animationController.reverse();
    if (widget.itemCount -1 == widget.itemIndex)
    await Future.delayed(Duration(milliseconds: (widget.itemCount - widget.itemIndex)*(_animationDelay/2).round()));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 128 * position * (1 - _animation.value)),
          child: Opacity(
            opacity: _animation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}