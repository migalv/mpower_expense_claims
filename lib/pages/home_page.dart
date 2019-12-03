import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expenses_bloc.dart';
import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/blocs/templates_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/pages/approved_expenses_page.dart';
import 'package:expense_claims_app/pages/expenses_page.dart';
import 'package:expense_claims_app/pages/templates_page.dart';
import 'package:expense_claims_app/utils.dart';
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
  HomeBloc _homeBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _homeBloc = Provider.of<HomeBloc>(context);
  }

  @override
  void dispose() {
    _homeBloc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        initialData: 0,
        stream: _homeBloc.pageIndex,
        builder: (context, snapshot) {
          List<Widget> pages = [
            BlocProvider<ExpensesBloc>(
              child: ExpensesPage(),
              initBloc: (_, bloc) =>
                  bloc ?? ExpensesBloc(expenseTypeStream: _homeBloc.pageIndex),
              onDispose: (_, bloc) => bloc.dispose(),
            ),
            BlocProvider<ExpensesBloc>(
              child: ExpensesPage(),
              initBloc: (_, bloc) =>
                  bloc ?? ExpensesBloc(expenseTypeStream: _homeBloc.pageIndex),
              onDispose: (_, bloc) => bloc.dispose(),
            ),
            ApprovedExpensesPage(),
          ];

          return Scaffold(
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.shifting,
              onTap: (int newIndex) => _homeBloc.setPageIndex(newIndex),
              currentIndex: snapshot.data,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  activeIcon: const Icon(
                    MdiIcons.homeVariant,
                    color: secondaryColor,
                  ),
                  icon: const Icon(
                    MdiIcons.homeVariant,
                    color: Colors.white38,
                  ),
                  title: Text(
                    'Expenses',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: const Icon(
                    Icons.description,
                    color: secondaryColor,
                  ),
                  icon: const Icon(
                    Icons.description,
                    color: Colors.white38,
                  ),
                  title: Text(
                    'Invoices',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: const Icon(
                    MdiIcons.fileDocumentBoxCheck,
                    color: secondaryColor,
                  ),
                  icon: const Icon(
                    MdiIcons.fileDocumentBoxCheck,
                    color: Colors.white38,
                  ),
                  title: Text(
                    'Approved',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            body: pages[snapshot.data],
            floatingActionButton: snapshot.data != 2
                ? FloatingActionButton.extended(
                    label: Text(
                      snapshot.data == 0 ? 'New expense claim' : 'New invoice',
                    ),
                    icon: Icon(
                      FontAwesomeIcons.plus,
                      size: 20,
                    ),
                    onPressed: () {
                      utils.push(
                        context,
                        BlocProvider<TemplatesBloc>(
                          initBloc: (_, bloc) =>
                              bloc ??
                              TemplatesBloc(
                                  expenseType:
                                      ExpenseType.values[snapshot.data]),
                          onDispose: (_, bloc) => bloc.dispose(),
                          child: TemplatesPage(),
                        ),
                      );
                    },
                  )
                : null,
          );
        },
      );
}
