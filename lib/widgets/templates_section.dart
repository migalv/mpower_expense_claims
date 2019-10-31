import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/expense_template_model.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TemplatesSection extends StatelessWidget {
  final List<Template> templatesList;
  final ExpenseType expenseType;
  final AnimationController bottomSheetController;
  final ScrollController scrollController;
  final Function onTap;

  const TemplatesSection({
    Key key,
    @required this.templatesList,
    @required this.expenseType,
    @required this.bottomSheetController,
    @required this.onTap,
    this.scrollController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> listWidgets = [_buildTitle(context)];

    listWidgets.addAll(
      templatesList
          .where((template) => template.expenseType == expenseType)
          .map(
            (template) => TemplateTile(
              template: template,
            ),
          ),
    );

    return Container(
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
      child: ListView(
        controller: scrollController,
        children: listWidgets,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 24.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Templates",
                style: Theme.of(context).textTheme.title,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: GestureDetector(
                child: Icon(
                  FontAwesomeIcons.plus,
                  color: secondaryColor,
                  size: 20.0,
                ),
                onTap: onTap,
              ),
            )
          ],
        ),
      );
}
