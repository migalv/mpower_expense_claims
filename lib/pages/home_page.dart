import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  Animation _colorTween,
      _colorTween2,
      _intTween,
      _intTween2,
      _intTweenText,
      _intTweenText2;
  AnimationController _animationController;
  HomeBloc _homeBloc;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 275));

    _colorTween = ColorTween(begin: Colors.blue, end: Colors.black38)
        .animate(_animationController);
    _colorTween2 = ColorTween(begin: Colors.black38, end: Colors.blue)
        .animate(_animationController);

    _intTween = IntTween().animate(_animationController);
    _intTween2 = IntTween().animate(_animationController);

    _intTweenText = IntTween(begin: 14, end: 10).animate(_animationController);
    _intTweenText2 = IntTween(begin: 10, end: 14).animate(_animationController);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _homeBloc = Provider.of<HomeBloc>(context);
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: StreamBuilder<int>(
          initialData: 0,
          stream: _homeBloc.pageIndex,
          builder: (context, snapshot) {
            // TODO Extraer widget
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
                              'Expense claims',
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
                                  MdiIcons.receipt,
                                  color: _colorTween.value,
                                  size: _intTween.value.toDouble(),
                                );
                              },
                            );
                          },
                        ),
                        onPressed: () {
                          if (snapshot.data == 1) {
                            _homeBloc.setPageIndex(0);
                            _pageController.animateToPage(
                              0,
                              duration: Duration(milliseconds: 275),
                              curve: Curves.ease,
                            );

                            if (_animationController.status ==
                                AnimationStatus.completed) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
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
                              'Invoices',
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
                                  FontAwesomeIcons.fileInvoiceDollar,
                                  color: _colorTween2.value,
                                  size: _intTween2.value.toDouble(),
                                );
                              },
                            );
                          },
                        ),
                        onPressed: () {
                          if (snapshot.data == 0) {
                            _homeBloc.setPageIndex(1);
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 275),
                              curve: Curves.ease,
                            );

                            if (_animationController.status ==
                                AnimationStatus.completed) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          _pageChanged(index);
        },
        children: <Widget>[
          Center(
            child: Container(
              child: Text('Empty Body 0'),
            ),
          ),
          Center(
            child: Container(
              child: Text('Empty Body 3'),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _pageChanged(int index) {
    _homeBloc.setPageIndex(index);

    if (_animationController.status == AnimationStatus.completed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }
}
