import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/blocs/templates_section_bloc.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/utils.dart';
import 'package:flutter/material.dart';

class TemplateTile extends StatelessWidget {
  final Template template;
  final PageController pageController;

  const TemplateTile({
    Key key,
    @required this.template,
    @required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ExpenseFormSectionBloc expenseFormSectionBloc =
        Provider.of<ExpenseFormSectionBloc>(context);
    TemplatesSectionBloc templatesSectionBloc =
        Provider.of<TemplatesSectionBloc>(context);

    return Container(
      margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white10,
      ),
      child: StreamBuilder<List<Template>>(
        initialData: [],
        stream: templatesSectionBloc.selectedTemplates,
        builder: (context, snapshot) {
          List<Template> selectedTemplates = snapshot.data;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Selection mode OFF
              if (selectedTemplates.isNotEmpty) {
                selectedTemplates.contains(template)
                    ? templatesSectionBloc.removeTemplate(template)
                    : templatesSectionBloc.addTemplate(template);
              } else {
                expenseFormSectionBloc.setTemplate(template);
                pageController.animateTo(MediaQuery.of(context).size.width,
                    duration: Duration(milliseconds: 275),
                    curve: Curves.easeIn);
              }
            },
            onLongPress: () {
              // Selection mode ON
              if (selectedTemplates.isEmpty) {
                templatesSectionBloc.addTemplate(template);
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      utils.buildCategoryIcon(
                          repository.getCategoryWithId(template.category)),
                      Flexible(
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
}
