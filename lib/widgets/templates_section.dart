import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/templates_section_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';

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
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
        List<Widget> listWidgets = [_buildTitle(context)];

        if (snapshot.data.isEmpty)
          listWidgets.add(_buildPlaceholder());
        else
          listWidgets.addAll(snapshot.data.map(
            (template) => TemplateTile(
              template: template,
              pageController: pageController,
            ),
          ));

        return ListView(
          controller: scrollController,
          children: listWidgets,
          shrinkWrap: true,
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context) => Container(
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
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: FlatButton(
                child: Text('Continue'),
                textColor: secondaryColor,
                onPressed: onPressed,
              ),
            )
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
              Text(
                "☹️",
                style: TextStyle(fontSize: 24.0),
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
}
