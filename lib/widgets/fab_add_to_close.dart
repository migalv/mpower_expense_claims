import 'package:flutter/material.dart';
import 'dart:math' as math;

class FabAddToClose extends StatefulWidget {
  final Function _onPressed;
  final AnimationController _controller;

  const FabAddToClose({
    @required onPressed,
    @required controller,
  })  : _onPressed = onPressed,
        _controller = controller;

  @override
  _FabAddToCloseState createState() => _FabAddToCloseState();
}

class _FabAddToCloseState extends State<FabAddToClose>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      child: AnimatedBuilder(
        animation: widget._controller,
        builder: (BuildContext context, Widget child) {
          return Transform(
            transform:
                Matrix4.rotationZ(widget._controller.value * 0.5 * math.pi),
            alignment: FractionalOffset.center,
            child:
                Icon(widget._controller.isDismissed ? Icons.add : Icons.close),
          );
        },
      ),
      onPressed: () {
        if (widget._controller.isDismissed) {
          widget._controller.forward();
        } else {
          widget._controller.reverse();
        }

        widget._onPressed();
      },
    );
  }
}
