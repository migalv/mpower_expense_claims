import 'package:expense_claims_app/models/expense_template_model.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';

class TemplatesList extends StatelessWidget {
  final List<ExpenseTemplate> templatesList;

  const TemplatesList({Key key, this.templatesList}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<Widget> widgetList = [_buildTitle(context)];

    widgetList.addAll(templatesList
        .map((template) => TemplateTile(template: template))
        .toList());

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
      child: ListView(
        children: widgetList,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 0.0, top: 16.0),
        child: Text(
          "Templates",
          style: Theme.of(context).textTheme.title,
        ),
      );
}
