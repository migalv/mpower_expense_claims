import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class FabOptionModel {
  final String label;
  final Function action;

  FabOptionModel({
    this.label,
    this.action,
  });
}

class FabWithOptions extends StatefulWidget {
  final FabOptionModel fabOption1, fabOption2;
  final Function onPressed;

  const FabWithOptions({
    Key key,
    @required this.fabOption1,
    this.fabOption2,
    @required this.onPressed,
  }) : super(key: key);

  @override
  _FabWithOptionsState createState() => _FabWithOptionsState();
}

class _FabWithOptionsState extends State<FabWithOptions>
    with TickerProviderStateMixin {
  AnimationController _controller;

  _FabWithOptionsState();

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 125),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(bottom: 8.0),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.0, 1.0, curve: Curves.easeOut),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(toBeginningOfSentenceCase(widget.fabOption1.label)
                      .replaceAll('_', ' ')),
                  elevation: 2.0,
                  color: Colors.white,
                  onPressed: () {
                    _controller.reverse();
                    widget.fabOption1.action();
                  },
                ),
                Container(
                  width: 8.0,
                ),
              ],
            ),
          ),
        ),
        widget.fabOption2 == null
            ? Container()
            : Container(
                margin: EdgeInsets.only(bottom: 16.0),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: Interval(0.0, 0.0, curve: Curves.easeOut),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                            toBeginningOfSentenceCase(widget.fabOption2.label)
                                .replaceAll('_', ' ')),
                        elevation: 2.0,
                        color: Colors.white,
                        onPressed: () {
                          _controller.reverse();
                          widget.fabOption2.action();
                        },
                      ),
                      Container(
                        width: 8.0,
                      ),
                    ],
                  ),
                ),
              ),
        FloatingActionButton(
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
        ),
      ],
    );
  }
}
