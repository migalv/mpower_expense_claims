import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/templates_section_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TemplatesSection extends StatelessWidget {
  final ScrollController scrollController;
  final Function onPressed;
  final PageController pageController;

  const TemplatesSection({
    Key key,
    @required this.onPressed,
    this.scrollController,
    @required this.pageController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TemplatesSectionBloc bloc = Provider.of<TemplatesSectionBloc>(context);

    return StreamBuilder<List<Template>>(
      stream: bloc.templates,
      builder: (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
        List<Widget> listWidgets = [_buildTitle(context, bloc)];

        if (snapshot == null || snapshot.data == null || snapshot.data.isEmpty)
          listWidgets.add(_buildPlaceholder());
        else
          listWidgets.addAll(
            snapshot.data.map(
              (template) => TemplateTile(
                template: template,
                pageController: pageController,
              ),
            ),
          );

        return ListView(
          controller: scrollController,
          children: listWidgets,
          shrinkWrap: true,
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context, TemplatesSectionBloc bloc) =>
      Container(
        height: 48,
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(left: 24.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                "Templates",
                style: Theme.of(context).textTheme.title,
              ),
            ),
            StreamBuilder<List<Template>>(
              stream: repository.selectedTemplates,
              initialData: [],
              builder: (context, snapshot) => Container(
                margin: EdgeInsets.only(right: 12.0),
                child: FlatButton(
                  child: Text(snapshot.data.length >= 1 ? 'Delete' : 'Skip'),
                  textColor: secondaryColor,
                  onPressed: snapshot.data.length >= 1
                      ? () => _deleteTemplates(context)
                      : onPressed,
                ),
              ),
            ),
          ],
        ),
      );

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

  void _deleteTemplates(BuildContext context) async {
    bool delete = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(
              "Create template",
              style: Theme.of(context).textTheme.title,
            ),
            content: Text(
              "How do you want to name your new template?",
              style: Theme.of(context).textTheme.subtitle,
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
                  "Create",
                ),
                onPressed: () => Navigator.of(context).pop(true),
                color: secondaryColor,
                textColor: black60,
              ),
            ],
          ),
        ) ??
        false;

    if (delete) repository.deleteTemplates();
  }
}
