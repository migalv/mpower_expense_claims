import 'package:flutter/material.dart';

class NavigationBarWithFAB extends StatefulWidget {
  const NavigationBarWithFAB({
    Key key,
    @required AnimationController animationController,
    @required int index,
    @required Function onPressed,
    @required String label1,
    @required String label2,
    @required IconData icon1,
    @required IconData icon2,
  })  : _animationController = animationController,
        _index = index,
        _onPressed = onPressed,
        _label1 = label1,
        _label2 = label2,
        _icon1 = icon1,
        _icon2 = icon2,
        super(key: key);

  final AnimationController _animationController;
  final int _index;
  final Function _onPressed;
  final String _label1, _label2;
  final IconData _icon1, _icon2;

  @override
  _NavigationBarWithFABState createState() => _NavigationBarWithFABState();
}

class _NavigationBarWithFABState extends State<NavigationBarWithFAB>
    with SingleTickerProviderStateMixin {
  Animation _colorTween,
      _colorTween2,
      _intTween,
      _intTween2,
      _intTweenText,
      _intTweenText2;

  @override
  void initState() {
    _colorTween = ColorTween(begin: Colors.blue, end: Colors.black38)
        .animate(widget._animationController);
    _colorTween2 = ColorTween(begin: Colors.black38, end: Colors.blue)
        .animate(widget._animationController);

    _intTween =
        IntTween(begin: 24, end: 20).animate(widget._animationController);
    _intTween2 =
        IntTween(begin: 20, end: 24).animate(widget._animationController);

    _intTweenText =
        IntTween(begin: 14, end: 10).animate(widget._animationController);
    _intTweenText2 =
        IntTween(begin: 10, end: 14).animate(widget._animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Container(
        height: 64,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: FlatButton.icon(
                label: AnimatedBuilder(
                  animation: _intTweenText,
                  builder: (context, child) {
                    return Text(
                      widget._label1,
                      style: Theme.of(context).textTheme.body2.copyWith(
                            fontSize: _intTweenText.value.toDouble(),
                            color: _colorTween.value,
                          ),
                    );
                  },
                ),
                icon: AnimatedBuilder(
                  animation: _intTween,
                  builder: (context, snapshot) {
                    return AnimatedBuilder(
                      animation: _colorTween,
                      builder: (context, child) {
                        return Icon(
                          widget._icon1,
                          color: _colorTween.value,
                          size: _intTween.value.toDouble(),
                        );
                      },
                    );
                  },
                ),
                onPressed: () {
                  if (widget._index == 1) {
                    widget._onPressed(0);

                    if (widget._animationController.status ==
                        AnimationStatus.completed) {
                      widget._animationController.forward();
                    } else {
                      widget._animationController.reverse();
                    }
                  }
                },
              ),
            ),
            Container(
              width: 56.0,
            ),
            Expanded(
              child: FlatButton.icon(
                label: AnimatedBuilder(
                  animation: _intTweenText2,
                  builder: (context, child) {
                    return Text(
                      widget._label2,
                      style: Theme.of(context).textTheme.body2.copyWith(
                            fontSize: _intTweenText2.value.toDouble(),
                            color: _colorTween2.value,
                          ),
                    );
                  },
                ),
                icon: AnimatedBuilder(
                  animation: _intTween2,
                  builder: (context, snapshot) {
                    return AnimatedBuilder(
                      animation: _colorTween2,
                      builder: (context, child) {
                        return Icon(
                          widget._icon2,
                          color: _colorTween2.value,
                          size: _intTween2.value.toDouble(),
                        );
                      },
                    );
                  },
                ),
                onPressed: () {
                  if (widget._index == 0) {
                    widget._onPressed(1);

                    if (widget._animationController.status ==
                        AnimationStatus.completed) {
                      widget._animationController.forward();
                    } else {
                      widget._animationController.reverse();
                    }
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
