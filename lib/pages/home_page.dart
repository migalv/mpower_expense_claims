import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/blocs/expenses_bloc.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/templates_section_bloc.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/expenses_page.dart';
import 'package:expense_claims_app/widgets/expense_form_section.dart';
import 'package:expense_claims_app/widgets/fab_add_to_close.dart';
import 'package:expense_claims_app/widgets/navigation_bar_with_fab.dart';
import 'package:expense_claims_app/widgets/templates_section.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomePage extends StatefulWidget {
  final int lastPageIndex;

  const HomePage({Key key, this.lastPageIndex = 0}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  PageController _pageController;
  PageController _bottomSheetPageController;
  AnimationController _navBarController, _bottomSheetController, _fabController;
  HomeBloc _homeBloc;
  Tween<Offset> _tween = Tween(begin: Offset(0, 2), end: Offset(0, 0));
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ExpenseFormSectionBloc _expenseFormBloc;

  @override
  void initState() {
    super.initState();

    _bottomSheetController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fabController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _homeBloc = Provider.of<HomeBloc>(context);

    _expenseFormBloc =
        ExpenseFormSectionBloc(expenseTypeStream: _homeBloc.pageIndex);

    if (_pageController == null)
      _pageController = PageController(
        initialPage: _homeBloc.pageIndex.value,
        keepPage: true,
      );

    if (_bottomSheetPageController == null)
      _bottomSheetPageController = PageController(
        initialPage: 0,
        keepPage: true,
      );

    if (_navBarController == null)
      _navBarController = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 275),
          value: _homeBloc.pageIndex.value.toDouble());
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    _navBarController.dispose();
    _bottomSheetController.dispose();
    _fabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        initialData: 0,
        builder: (context, snapshot) => Scaffold(
          key: _scaffoldKey,
          bottomNavigationBar: StreamBuilder<int>(
            stream: _homeBloc.pageIndex,
            builder: (context, pageIndexSnapshot) => NavigationBarWithFAB(
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
          ),
          body: Stack(
            children: <Widget>[
              PageView(
                controller: _pageController,
                onPageChanged: (int index) {
                  _pageChanged(index);
                },
                children: <Widget>[
                  BlocProvider<ExpensesBloc>(
                    child: ExpensesPage(expenseType: ExpenseType.EXPENSE_CLAIM),
                    initBloc: (_, bloc) =>
                        ExpensesBloc(expenseType: ExpenseType.EXPENSE_CLAIM),
                    onDispose: (_, bloc) => bloc.dispose(),
                  ),
                  BlocProvider<ExpensesBloc>(
                    child: ExpensesPage(expenseType: ExpenseType.INVOICE),
                    initBloc: (_, bloc) =>
                        ExpensesBloc(expenseType: ExpenseType.INVOICE),
                    onDispose: (_, bloc) => bloc.dispose(),
                  ),
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
                            color: Color(0x1affffff),
                            offset: Offset(0, -4),
                            blurRadius: 5.0,
                          )
                        ],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32.0),
                          topRight: Radius.circular(32.0),
                        ),
                      ),
                      child: PageView(
                        controller: _bottomSheetPageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          BlocProvider<TemplatesSectionBloc>(
                            child: TemplatesSection(
                              scrollController: scrollController,
                              pageController: _bottomSheetPageController,
                              expenseFormBloc: _expenseFormBloc,
                              onPressed: () {
                                _bottomSheetPageController.animateTo(
                                    MediaQuery.of(context).size.width,
                                    duration: Duration(milliseconds: 275),
                                    curve: Curves.easeIn);
                                _expenseFormBloc.setTemplate(null);
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
                                _bottomSheetPageController.animateTo(0,
                                    duration: Duration(milliseconds: 275),
                                    curve: Curves.easeIn);
                              },
                              scaffoldKey: _scaffoldKey,
                              onDonePressed: () async {
                                _playAnimation(_fabController);

                                await _playAnimation(_bottomSheetController);

                                _bottomSheetPageController.animateTo(0,
                                    duration: Duration(milliseconds: 1),
                                    curve: Curves.easeIn);
                              },
                            ),
                            initBloc: (_, bloc) => bloc ?? _expenseFormBloc,
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
            controller: _fabController,
            onPressed: () {
              _playAnimation(_bottomSheetController);
            },
          ),
        ),
      );

  void _pageChanged(int index) {
    _homeBloc.setPageIndex(index);

    if (_navBarController.status == AnimationStatus.completed) {
      _navBarController.reverse();
    } else {
      _navBarController.forward();
    }
  }

  TickerFuture _playAnimation(AnimationController controller) =>
      controller.isDismissed ? controller.forward() : controller.reverse();
}
