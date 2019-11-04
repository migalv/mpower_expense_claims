import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/form_template_model.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';

class TemplateList extends StatelessWidget {
  final List<FormTemplate> templatesList;
  final ExpenseType expenseType;
  final AnimationController bottomSheetController;
  final ScrollController scrollController;
  final HomeBloc homeBloc;

  const TemplateList(
      {Key key,
      @required this.templatesList,
      @required this.expenseType,
      @required this.bottomSheetController,
      this.scrollController,
      this.homeBloc})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> listWidgets = [_buildTitle(context)];

    listWidgets.addAll(templatesList
        .where((template) => template.expenseType == expenseType)
        .map((template) => TemplateTile(
              template: template,
              bottomSheetController: bottomSheetController,
              homeBloc: homeBloc,
            )));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          new BoxShadow(
            color: Colors.black12,
            offset: new Offset(0, -2),
            blurRadius: 2.0,
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.0),
          topRight: Radius.circular(32.0),
        ),
      ),
      child: Stack(
        children: <Widget>[
          ListView(
            controller: scrollController,
            children: listWidgets,
          ),
          Align(alignment: Alignment.bottomCenter, child: _buildCreateButton()),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 16.0),
        child: Text(
          "Your templates",
          style: Theme.of(context).textTheme.title,
        ),
      );

  Widget _buildCreateButton() => Padding(
        padding: EdgeInsets.only(bottom: 32.0),
        child: FlatButton(
          padding: EdgeInsets.all(14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          color: secondaryLightColor,
          child: Text(
            'Create new ' +
                (expenseType == ExpenseType.EXPENSE_CLAIM
                    ? "Expense claim"
                    : "Invoice"),
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () async {
            if (bottomSheetController.isCompleted) {
              await bottomSheetController.reverse();
              homeBloc.setBottomSheetState(BottomSheetState.FORM);
              bottomSheetController.forward();
            }
          },
        ),
      );
}
