import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/expense_claims_page.dart';
import 'package:expense_claims_app/pages/new_expense_page.dart';
import 'package:expense_claims_app/respository.dart';
import 'package:expense_claims_app/widgets/expense_tile.dart';
import 'package:expense_claims_app/widgets/fab_add_to_close.dart';
import 'package:expense_claims_app/widgets/navigation_bar_with_fab.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  AnimationController _navBarController, _bottomSheetController;
  HomeBloc _homeBloc;
  Tween<Offset> _tween = Tween(begin: Offset(0, 1), end: Offset(0, 0));

  @override
  void initState() {
    super.initState();

    _navBarController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 275));
    _bottomSheetController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _homeBloc = Provider.of<HomeBloc>(context);
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    _navBarController.dispose();
    _bottomSheetController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: StreamBuilder<int>(
        initialData: 0,
        stream: _homeBloc.pageIndex,
        builder: (context, snapshot) => NavigationBarWithFAB(
          animationController: _navBarController,
          index: snapshot.data,
          icon1: MdiIcons.receipt,
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
      body: StreamBuilder<int>(
          stream: _homeBloc.pageIndex,
          builder: (context, pageIndexSnapshot) {
            return Stack(
              children: <Widget>[
                PageView(
                  controller: _pageController,
                  onPageChanged: (int index) {
                    _pageChanged(index);
                  },
                  children: <Widget>[
                    ExpenseClaimsPage(),
                    Center(
                      child: Container(
                        child: Text('Empty Body 3'),
                      ),
                    )
                  ],
                ),
                SizedBox.expand(
                  child: SlideTransition(
                    position: _tween.animate(_bottomSheetController),
                    child: DraggableScrollableSheet(
                      builder: (BuildContext context,
                              ScrollController scrollController) =>
                          BlocProvider<NewExpenseBloc>(
                        child:
                            NewExpensePage(scrollController: scrollController),
                        initBloc: (_, bloc) =>
                            bloc ??
                            NewExpenseBloc(
                                expenseType: pageIndexSnapshot.data == 0
                                    ? ExpenseType.EXPENSE_CLAIM
                                    : ExpenseType.INVOICE),
                        onDispose: (_, bloc) => bloc?.dispose(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FabAddToClose(
        onPressed: () {
          if (_bottomSheetController.isDismissed)
            _bottomSheetController.forward();
          else if (_bottomSheetController.isCompleted)
            _bottomSheetController.reverse();
        },
      ),
    );
  }

  void _pageChanged(int index) {
    _homeBloc.setPageIndex(index);

    if (_navBarController.status == AnimationStatus.completed) {
      _navBarController.reverse();
    } else {
      _navBarController.forward();
    }
  }
}
