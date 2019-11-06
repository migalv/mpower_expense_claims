import 'package:expense_claims_app/colors.dart';
import 'package:flutter/material.dart';

class NavigationBarWithFAB extends StatefulWidget {
  const NavigationBarWithFAB({
    Key key,
    @required AnimationController animationController,
    @required int index,
    @required Function onItemPressed,
    @required IconData icon1,
    @required IconData icon2,
  })  : _animationController = animationController,
        _index = index,
        _onItemPressed = onItemPressed,
        _icon1 = icon1,
        _icon2 = icon2,
        super(key: key);

  final AnimationController _animationController;
  final int _index;
  final Function _onItemPressed;
  final IconData _icon1, _icon2;

  @override
  _NavigationBarWithFABState createState() => _NavigationBarWithFABState();
}

class _NavigationBarWithFABState extends State<NavigationBarWithFAB>
    with SingleTickerProviderStateMixin {
  Animation _colorTween, _colorTween2, _intTween, _intTween2;

  @override
  void initState() {
    _colorTween = ColorTween(begin: secondaryColor, end: Colors.white30)
        .animate(widget._animationController);
    _colorTween2 = ColorTween(begin: Colors.white30, end: secondaryColor)
        .animate(widget._animationController);

    _intTween =
        IntTween(begin: 24, end: 20).animate(widget._animationController);
    _intTween2 =
        IntTween(begin: 20, end: 24).animate(widget._animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 10.0,
      shape: CircularNotchedRectangle(),
      child: Container(
        height: 64,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: IconButton(
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
                    widget._onItemPressed(0);

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
              width: 32.0,
            ),
            Expanded(
              child: IconButton(
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
                    widget._onItemPressed(1);

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
