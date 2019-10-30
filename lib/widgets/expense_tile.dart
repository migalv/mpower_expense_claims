import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_tile_bloc.dart';
import 'package:expense_claims_app/models/category_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class ExpenseTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ExpenseTileState();
}

class _ExpenseTileState extends State<ExpenseTile>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  final Animatable<double> _sizeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ),
      _rotationTween = Tween<double>(begin: 0.0, end: 0.5);
  Animation<double> _sizeAnimation, _rotateAnimation;
  bool _isExpanded = false;
  ExpenseTileBloc _expenseTileBloc;

  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _sizeAnimation = _sizeTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
    _rotateAnimation = _rotationTween.animate(
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _expenseTileBloc = Provider.of<ExpenseTileBloc>(context);
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<Expense>(
      stream: _expenseTileBloc.expense,
      builder: (context, snapshot) {
        Expense expense = snapshot.data;

        if (expense == null) return Container();

        return GestureDetector(
          onTap: _toggleExpand,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x10000000),
                  offset: Offset(6, 6),
                  blurRadius: 6.0,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 16.0,
                      ),
                      _buildCategoryIcon(_expenseTileBloc.category),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, top: 16.0),
                            child: Text(
                              _expenseTileBloc.category.name,
                              style: Theme.of(context).textTheme.title,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, top: 8.0, bottom: 16.0),
                            child: Text(
                              timeago.format(expense.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .body1
                                  .copyWith(color: Colors.black38),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        child: Chip(
                          backgroundColor: Colors.blue[50],
                          label: Text(
                            '${expense.gross.toString()} ${_expenseTileBloc.currencySymbol ?? ''}',
                            style: Theme.of(context).textTheme.subhead.copyWith(
                                  color: Colors.blue,
                                ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 8.0, right: 12.0),
                        alignment: Alignment.bottomRight,
                        child: RotationTransition(
                          turns: _rotateAnimation,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black38,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizeTransition(
                    axisAlignment: 0.0,
                    axis: Axis.vertical,
                    sizeFactor: _sizeAnimation,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(72.0, 0.0, 16.0, 16.0),
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: _buildSection(
                                    'Approved by', expense.approvedByName),
                              ),
                              Expanded(
                                child: _buildSection(
                                    'Country', _expenseTileBloc.country),
                              ),
                            ],
                          ),
                          Container(height: 12.0),
                          _buildSection('Description', expense.description),
                          Container(height: 12.0),
                          Row(
                            children: <Widget>[
                              Expanded(
                                  child: _buildSection(
                                      'Net cost', expense.net.toString())),
                              Expanded(
                                  child: _buildSection(
                                      'VAT', '${expense.vat.toString()} %')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });

  Widget _buildSection(String title, String desc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.body2,
          ),
          Container(
            height: 4.0,
          ),
          Text(
            desc ?? '',
            style: Theme.of(context)
                .textTheme
                .body2
                .copyWith(fontWeight: FontWeight.normal),
          ),
        ],
      );

  Widget _buildCategoryIcon(Category category) => Container(
        width: 48.0,
        height: 48.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: category.color,
            width: 2.0,
          ),
        ),
        child: Icon(
          category.icon,
          color: Colors.black45,
        ),
      );

  //
  // METHODS
  _toggleExpand() {
    _isExpanded = !_isExpanded;

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