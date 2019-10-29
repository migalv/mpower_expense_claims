import 'package:flutter/material.dart';
import 'dart:math' as math;

class FabAddToClose extends StatefulWidget {
  final Function onPressed;

  const FabAddToClose({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  _FabAddToCloseState createState() => _FabAddToCloseState();
}

class _FabAddToCloseState extends State<FabAddToClose>
    with TickerProviderStateMixin {
  AnimationController _controller;

  _FabAddToCloseState();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget child) {
          return Transform(
            transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
            alignment: FractionalOffset.center,
            child: Icon(_controller.isDismissed ? Icons.add : Icons.close),
          );
        },
      ),
      onPressed: () {
        if (_controller.isDismissed) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
        widget.onPressed();
      },
    );
  }
}
