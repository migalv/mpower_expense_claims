import 'package:expense_claims_app/models/expense_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ExpenseTile extends StatefulWidget {
  final Expense _expense;

  ExpenseTile({@required Expense expense}) : _expense = expense;

  @override
  State<StatefulWidget> createState() => _SectionState();
}

class _SectionState extends State<ExpenseTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  static final Animatable<double> _sizeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );
  Animation<double> _sizeAnimation;
  bool _isExpanded = false;

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeAnimation = _sizeTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Color(0xfff1f1f1)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 0.0),
                    alignment: Alignment.centerRight,
                    child: Chip(
                      backgroundColor: Colors.blue,
                      label: Text(
                        '${widget._expense.gross.toString()} €',
                        style: Theme.of(context).textTheme.title.copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                    child: Text(
                      "Transport",
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      timeago.format(widget._expense.date),
                      style: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(color: Colors.blue),
                    ),
                  ),
                  SizeTransition(
                    axisAlignment: 0.0,
                    axis: Axis.vertical,
                    sizeFactor: _sizeAnimation,
                    child: Container(
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 56.0, right: 20.0, top: 10.0),
                        child: Column(children: [
                          Text('hey'),
                          Text('hey'),
                          Text('hey'),
                          Text('hey'),
                          Text('hey'),
                          Text('hey'),
                          Text('hey'),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  // METHODS
  _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    switch (_sizeAnimation.status) {
      case AnimationStatus.completed:
        _controller.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }
}
