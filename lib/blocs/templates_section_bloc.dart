import 'dart:async';

import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/foundation.dart';

class TemplatesSectionBloc {
  final Stream<int> _expenseTypeStream;
  List<StreamSubscription> _streamSubscriptions = [];
  List<Template> _templates = [];
  int _expenseType = 0;

  //
  //  OUTPUT
  Stream<List<Template>> get templates => _templatesController.stream;

  // Subjects
  final _templatesController = StreamController<List<Template>>();

  TemplatesSectionBloc({@required Stream<int> expenseTypeStream})
      : _expenseTypeStream = expenseTypeStream {
    _listenToTemplateChanges();
    _listenToExpenseTypeChanges();
  }

  void _listenToTemplateChanges() {
    _streamSubscriptions.add(repository.templates.listen((List<Template> list) {
      _updateTemplates(list);
    }));
  }

  void _listenToExpenseTypeChanges() {
    _streamSubscriptions.add(_expenseTypeStream.listen(
      (expenseType) {
        _expenseType = expenseType ?? _expenseType;

        _updateTemplates(repository.templates.value);
      },
    ));
  }

  void _updateTemplates(List<Template> list) {
    _templates.clear();
    _templates.addAll(list?.where((template) =>
            template.expenseType == ExpenseType.values[_expenseType]) ??
        []);
    _templatesController.add(_templates);
  }

  void dispose() {
    _templatesController.close();

    _streamSubscriptions.forEach((s) => s.cancel());
  }
}
