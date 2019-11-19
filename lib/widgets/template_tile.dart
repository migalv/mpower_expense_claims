import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/expense_form_section_bloc.dart';
import 'package:expense_claims_app/colors.dart';
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

    return Container(
      margin: EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white10,
      ),
      child: StreamBuilder<List<Template>>(
        initialData: [],
        stream: repository.selectedTemplates,
        builder: (context, snapshot) {
          List<Template> selectedTemplates = snapshot.data;
          bool selected = selectedTemplates.contains(template);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // Selection mode OFF
              if (selectedTemplates.isNotEmpty) {
                selected
                    ? repository.deselectTemplate(template)
                    : repository.selectTemplate(template);
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
                repository.selectTemplate(template);
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
}
