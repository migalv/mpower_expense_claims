import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';

class TemplateTile extends StatelessWidget {
  final Template template;
  final ExpenseFormSectionBloc expenseFormBloc;
  final PageController pageController;

  const TemplateTile(
      {Key key,
      @required this.template,
      @required this.expenseFormBloc,
      @required this.pageController})
      : super(key: key);

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
      onTap: () {
        expenseFormBloc.setTemplate(template);
        pageController.animateTo(MediaQuery.of(context).size.width,
            duration: Duration(milliseconds: 275), curve: Curves.easeIn);
      },
    );
  }
}
