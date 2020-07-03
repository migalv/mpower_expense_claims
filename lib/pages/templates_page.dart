import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/blocs/templates_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/pages/new_expense_page.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/custom_app_bar.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TemplatesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TemplatesBloc bloc = Provider.of<TemplatesBloc>(context);

    return StreamBuilder<List<Template>>(
      initialData: [],
      stream: bloc.templates,
      builder: (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
        List<Widget> listWidgets = [];

        if (snapshot == null || snapshot.data == null || snapshot.data.isEmpty)
          listWidgets.add(_buildPlaceholder());
        else
          listWidgets.addAll(
            snapshot.data.map(
              (template) => TemplateTile(
                template: template,
              ),
            ),
          );

        return Scaffold(
          appBar: CustomAppBar(
            title: 'Templates',
            actions: <Widget>[
              StreamBuilder<List<Template>>(
                  stream: bloc.selectedTemplates,
                  initialData: [],
                  builder: (context, snapshot) {
                    return FlatButton(
                      child:
                          Text(snapshot.data.length >= 1 ? 'Delete' : 'Skip'),
                      textColor: secondaryColor,
                      onPressed: snapshot.data.length >= 1
                          ? () => _deleteTemplates(context, bloc)
                          : () {
                              utils.push(
                                context,
                                BlocProvider<NewExpenseBloc>(
                                  initBloc: (_, b) =>
                                      b ??
                                      NewExpenseBloc(
                                          expenseType: bloc.expenseType),
                                  child: NewExpensePage(),
                                  onDispose: (_, b) => b.dispose(),
                                ),
                              );
                            },
                    );
                  }),
            ],
          ),
          body: ListView(
            children: listWidgets,
            shrinkWrap: true,
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() => Container(
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        decoration: BoxDecoration(
          color: secondary100Color,
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 4.0,
              ),
              Icon(
                FontAwesomeIcons.solidFrown,
                color: Colors.black38,
              ),
              Container(
                width: 16.0,
              ),
              Text(
                'You have not created any Template yet.',
                style: TextStyle(color: Colors.black54),
              )
            ],
          ),
        ),
      );

  void _deleteTemplates(
      BuildContext context, TemplatesBloc templatesSectionBloc) async {
    bool delete = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Delete templates",
              style: Theme.of(context).textTheme.headline6,
            ),
            content: Text(
              "Are you sure to delete these templates?",
              style: Theme.of(context).textTheme.subtitle2,
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Cancel",
                  style: Theme.of(context).textTheme.button,
                ),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              RaisedButton(
                child: Text(
                  "Delete",
                ),
                onPressed: () => Navigator.of(context).pop(true),
                color: secondaryColor,
                textColor: black60,
              ),
            ],
          ),
        ) ??
        false;

    if (delete) templatesSectionBloc.deleteTemplates();
  }
}
