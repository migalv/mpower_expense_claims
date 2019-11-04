import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/templates_section_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/expense_template_model.dart';
import 'package:expense_claims_app/widgets/template_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TemplatesSection extends StatelessWidget {
  final AnimationController bottomSheetController;
  final ScrollController scrollController;
  final Function onTap;

  const TemplatesSection({
    Key key,
    @required this.bottomSheetController,
    @required this.onTap,
    this.scrollController,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    TemplatesSectionBloc bloc = Provider.of<TemplatesSectionBloc>(context);

    return StreamBuilder<List<Template>>(
      stream: bloc.templates,
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<Template>> snapshot) {
        List<Widget> listWidgets = [_buildTitle(context)];

        listWidgets.addAll(
          snapshot.data
                  ?.map(
                    (template) => TemplateTile(
                      template: template,
                    ),
                  )
                  ?.toList() ??
              [],
        );

        return ListView(children: listWidgets);
      },
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
