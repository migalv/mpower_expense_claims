import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/new_expense_bloc.dart';
import 'package:expense_claims_app/blocs/templates_bloc.dart';
import 'package:expense_claims_app/colors.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/pages/new_expense_page.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:expense_claims_app/widgets/tile_icon.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TemplateTile extends StatelessWidget {
  final Template template;
  const TemplateTile({
    Key key,
    @required this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NewExpenseBloc expenseFormSectionBloc =
        Provider.of<NewExpenseBloc>(context);
    TemplatesBloc templatesBloc = Provider.of<TemplatesBloc>(context);

    return Container(
      margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white10,
      ),
      child: StreamBuilder<List<Template>>(
        initialData: [],
        stream: templatesBloc.selectedTemplates,
        builder: (context, snapshot) {
          List<Template> selectedTemplates = snapshot.data;
          bool selected = selectedTemplates.contains(template);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Selection mode OFF
              if (selectedTemplates.isNotEmpty) {
                selected
                    ? templatesBloc.deselectTemplate(template)
                    : templatesBloc.selectTemplate(template);
              } else
                _onTemplatePressed(expenseFormSectionBloc, context);
            },
            onLongPress: () {
              // Selection mode ON
              if (selectedTemplates.isEmpty) {
                templatesBloc.selectTemplate(template);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      TileIcon(
                          iconData: repository
                              .getCategoryWithId(template.category)
                              ?.icon),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                template.name,
                                style: Theme.of(context).textTheme.title,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 16.0),
                              child: Text(
                                template.description,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context)
                                    .textTheme
                                    .body1
                                    .copyWith(fontSize: 12.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      selectedTemplates.isNotEmpty
                          ? Container(
                              margin: EdgeInsets.only(right: 16),
                              child: CircleAvatar(
                                backgroundColor:
                                    selected ? secondaryColor : Colors.white10,
                                child: selected
                                    ? Icon(
                                        Icons.check,
                                        size: 16,
                                      )
                                    : Container(),
                              ),
                              width: 24.0,
                              height: 24.0,
                              padding: EdgeInsets.all(2.0),
                              decoration: BoxDecoration(
                                color:
                                    selected ? backgroundColor : Colors.white10,
                                shape: BoxShape.circle,
                              ),
                            )
                          : template.createdBy == repository.currentUserId
                              ? Container(
                                  margin: EdgeInsets.only(right: 8),
                                  child: IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.pen,
                                      size: 16,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () => _onTemplatePressed(
                                      expenseFormSectionBloc,
                                      context,
                                      edit: true,
                                    ),
                                  ),
                                )
                              : Container(),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onTemplatePressed(
      NewExpenseBloc expenseFormSectionBloc, BuildContext context,
      {bool edit = false}) {
    utils.push(
      context,
      BlocProvider<NewExpenseBloc>(
        initBloc: (_, b) =>
            b ??
            NewExpenseBloc(
                expenseType: template.expenseType,
                templateToBeEdited: template),
        child: NewExpensePage(),
        onDispose: (_, b) => b.dispose(),
      ),
    );
  }
}
