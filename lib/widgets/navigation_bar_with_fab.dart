import 'package:flutter/material.dart';

class NavigationBarWithFAB extends StatefulWidget {
  final Function onFirstItemPressed, onSecondItemPressed;
  final IconData firstItemIcon, secondItemIcon;
  final String firstItemLabel, secondItemLabel;
  final Color itemsColor;

  const NavigationBarWithFAB({
    Key key,
    @required this.onFirstItemPressed,
    @required this.onSecondItemPressed,
    @required this.firstItemIcon,
    @required this.secondItemIcon,
    @required this.firstItemLabel,
    @required this.secondItemLabel,
    @required this.itemsColor,
  }) : super(key: key);

  @override
  _NavigationBarWithFABState createState() => _NavigationBarWithFABState();
}

class _NavigationBarWithFABState extends State<NavigationBarWithFAB>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _colorTween,
      _colorTween2,
      _intTween,
      _intTween2,
      _intTweenText,
      _intTweenText2;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 275));

    _colorTween = ColorTween(begin: widget.itemsColor, end: Colors.black38)
        .animate(_animationController);
    _colorTween2 = ColorTween(begin: Colors.black38, end: widget.itemsColor)
        .animate(_animationController);

    _intTween = IntTween(begin: 24, end: 20).animate(_animationController);
    _intTween2 = IntTween(begin: 20, end: 24).animate(_animationController);

    _intTweenText = IntTween(begin: 14, end: 10).animate(_animationController);
    _intTweenText2 = IntTween(begin: 10, end: 14).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
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
                      widget.firstItemLabel,
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
                          widget.firstItemIcon,
                          color: _colorTween.value,
                          size: _intTween.value.toDouble(),
                        );
                      },
                    );
                  },
                ),
                onPressed: () {
                  if (widget.onFirstItemPressed()) _playAnimation();
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
                      widget.secondItemLabel,
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
                          widget.secondItemIcon,
                          color: _colorTween2.value,
                          size: _intTween2.value.toDouble(),
                        );
                      },
                    );
                  },
                ),
                onPressed: () {
                  if (widget.onSecondItemPressed()) _playAnimation();
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _playAnimation() {
    if (_animationController.status == AnimationStatus.completed)
      _animationController.forward();
    else
      _animationController.reverse();
  }
}
