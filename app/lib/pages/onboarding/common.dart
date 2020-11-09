

import 'package:flutter/material.dart';

class StepWidget extends StatefulWidget
{
  final Widget child;
  final int itemCount;
  StepWidget({@required this.child, @required this.itemCount, Key key}) : super(key: key);

  SteWidgetState createState() => SteWidgetState();
}

class SteWidgetState extends State<StepWidget>
{
  List<GlobalKey<ItemFaderState>> keys;

  void initState() {
    super.initState();
    keys = List.generate(widget.itemCount, (_) => GlobalKey<ItemFaderState>());
  }

  Widget build(BuildContext context)
  {
    return Column(
      children: [
        SizedBox(height: 32),
        Spacer(),
        widget.child,
        Spacer()
      ]
    );
  }
}

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
  //1 means its below, -1 means its above
  int position = 1;
  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    show();
  }

  Future<void> show() async {
    await Future.delayed(Duration(milliseconds: widget.itemIndex*40));
    setState(() => position = 1);
    _animationController.forward();
  }

  Future<void> hide() async {
    await Future.delayed(Duration(milliseconds: (widget.itemCount - widget.itemIndex)*40));
    setState(() => position = -1);
    _animationController.reverse();
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
          offset: Offset(0, 64 * position * (1 - _animation.value)),
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