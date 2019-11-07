import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/templates_section_bloc.dart';
import 'package:expense_claims_app/pages/expense_claims_page.dart';
import 'package:expense_claims_app/widgets/expense_form_section.dart';
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
  ),
      _pageController2 = PageController(
    initialPage: 0,
    keepPage: true,
  );
  AnimationController _navBarController, _bottomSheetController;
  HomeBloc _homeBloc;
  Tween<Offset> _tween = Tween(begin: Offset(0, 1), end: Offset(0, 0));
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    return StreamBuilder<int>(
        initialData: 0,
        stream: _homeBloc.pageIndex,
        builder: (context, pageIndexSnapshot) {
          return Scaffold(
            key: _scaffoldKey,
            bottomNavigationBar: NavigationBarWithFAB(
              animationController: _navBarController,
              index: pageIndexSnapshot.data,
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
            body: Stack(
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
                          Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, -2),
                              blurRadius: 6.0,
                            )
                          ],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32.0),
                            topRight: Radius.circular(32.0),
                          ),
                        ),
                        child: PageView(
                          controller: _pageController2,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            BlocProvider<TemplatesSectionBloc>(
                              child: TemplatesSection(
                                bottomSheetController: _bottomSheetController,
                                scrollController: scrollController,
                                onPressed: () {
                                  _pageController2.animateTo(
                                      MediaQuery.of(context).size.width,
                                      duration: Duration(milliseconds: 275),
                                      curve: Curves.easeIn);
                                },
                              ),
                              initBloc: (_, bloc) => TemplatesSectionBloc(
                                  expenseTypeStream: _homeBloc.pageIndex),
                              onDispose: (_, bloc) => bloc.dispose(),
                            ),
                            BlocProvider<ExpenseFormSectionBloc>(
                              child: ExpenseFormSection(
                                scrollController: scrollController,
                                onBackPressed: () {
                                  _pageController2.animateTo(0,
                                      duration: Duration(milliseconds: 275),
                                      curve: Curves.easeIn);
                                },
                                scaffoldKey: _scaffoldKey,
                              ),
                              initBloc: (_, bloc) =>
                                  bloc ??
                                  ExpenseFormSectionBloc(
                                      expenseTypeStream: _homeBloc.pageIndex),
                              onDispose: (_, bloc) => bloc.dispose(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FabAddToClose(
              onPressed: () {
                if (_bottomSheetController.isDismissed)
                  _bottomSheetController.forward();
                else if (_bottomSheetController.isCompleted)
                  _bottomSheetController.reverse();
              },
            ),
          );
        });
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
