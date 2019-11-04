import 'package:expense_claims_app/blocs/home_bloc.dart';
import 'package:expense_claims_app/models/form_template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/material.dart';

class TemplateTile extends StatelessWidget {
  final FormTemplate template;
  final AnimationController bottomSheetController;
  final HomeBloc homeBloc;

  const TemplateTile(
      {Key key, this.template, this.bottomSheetController, this.homeBloc})
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
      onTap: () async {
        if (bottomSheetController.isCompleted) {
          await bottomSheetController.reverse();
          homeBloc.setBottomSheetState(BottomSheetState.FORM);
          homeBloc.selectFormTemplate(template);
          bottomSheetController.forward();
        }
      },
    );
  }
}
