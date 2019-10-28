import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/new_expense_page.dart';
import 'package:expense_claims_app/widgets/navigation_bar_with_fab.dart';
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
  AnimationController _animationController;
  HomeBloc _homeBloc;
  bool _fabVisible = true;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 275));
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
      bottomNavigationBar: StreamBuilder<int>(
        initialData: 0,
        stream: _homeBloc.pageIndex,
        builder: (context, snapshot) => NavigationBarWithFAB(
          animationController: _animationController,
          index: snapshot.data,
          label1: 'Expense claims',
          icon1: MdiIcons.receipt,
          label2: 'Invoices',
          icon2: FontAwesomeIcons.fileInvoiceDollar,
          onItemPressed: (int index) {
            _homeBloc.setPageIndex(index);
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 275),
              curve: Curves.ease,
            );
          },
        ),
      ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _fabVisible
          ? StreamBuilder<int>(
              stream: _homeBloc.pageIndex,
              initialData: 0,
              builder: (context, pageIndexSnapshot) {
                return FloatingActionButton(
                  onPressed: () async {
                    setState(() {
                      _fabVisible = false;
                    });

                    await showBottomSheet(
                      builder: (_) {
                        return BlocProvider<NewExpenseBloc>(
                          child: NewExpensePage(),
                          initBloc: (_, bloc) =>
                              bloc ??
                              NewExpenseBloc(
                                  expenseType: pageIndexSnapshot.data == 0
                                      ? ExpenseType.EXPENSE_CLAIM
                                      : ExpenseType.INVOICE),
                          onDispose: (_, bloc) => bloc?.dispose(),
                        );
                      },
                      context: context,
                    ).closed;

                    setState(() {
                      _fabVisible = true;
                    });
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                );
              },
            )
          : null,
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
