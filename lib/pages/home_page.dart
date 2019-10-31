import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/custom_draggable_scrollable_sheet_bloc.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/expense_claims_page.dart';
import 'package:expense_claims_app/widgets/custom_draggable_scrollable_sheet.dart';
import 'package:expense_claims_app/widgets/fab_add_to_close.dart';
import 'package:expense_claims_app/widgets/navigation_bar_with_fab.dart';
import 'package:expense_claims_app/widgets/templates_section.dart';
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
  Widget selectedWidget, templates, form;

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
    templates = DraggableScrollableSheet(
      builder: (BuildContext context, ScrollController scrollController) =>
          TemplatesSection(
        bottomSheetController: _bottomSheetController,
        scrollController: scrollController,
        expenseType: ExpenseType.EXPENSE_CLAIM,
        templatesList: [],
        onTap: () {
          setState(() {
            selectedWidget = templates;
          });
        },
      ),
    );
    form = DraggableScrollableSheet(
      builder: (BuildContext context, ScrollController scrollController) =>
          Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x10000000),
              offset: Offset(0, -2),
              blurRadius: 6.0,
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.0),
            topRight: Radius.circular(32.0),
          ),
        ),
        child: FlatButton(
          child: Text('adio'),
          onPressed: () {
            setState(() {
              selectedWidget = form;
            });
          },
        ),
      ),
    );

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
                    child: AnimatedSwitcher(
                      duration: Duration(seconds: 1),
                      child: selectedWidget ?? templates,
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
