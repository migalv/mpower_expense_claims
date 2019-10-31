import 'package:expense_claims_app/models/expense_template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';

class TemplateTile extends StatelessWidget {
  final Template template;

  const TemplateTile({Key key, this.template}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(repository.getCategoryWithId(template.category).icon),
      title: Text(
        template.name,
        style: Theme.of(context).textTheme.title,
      ),
      subtitle: Text(
        template.description,
        style: Theme.of(context).textTheme.subtitle,
      ),
      onTap: () async {},
    );
  }
}
