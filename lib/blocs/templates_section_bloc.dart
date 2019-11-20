import 'dart:async';

import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class TemplatesSectionBloc {
  final Stream<int> _expenseTypeStream;
  List<StreamSubscription> _streamSubscriptions = [];
  List<Template> _templates = [];
  int _expenseType = 0;
  List<Template> _selectedTemplates;

  //
  //  OUTPUT
  Stream<List<Template>> get templates => _templatesController.stream;
  ValueObservable<List<Template>> get selectedTemplates =>
      _selectedTemplatesController.stream;

  // Subjects
  final _templatesController = BehaviorSubject<List<Template>>();
  final _selectedTemplatesController = BehaviorSubject<List<Template>>();

  TemplatesSectionBloc({@required Stream<int> expenseTypeStream})
      : _expenseTypeStream = expenseTypeStream {
    _selectedTemplates = [];
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

  void selectTemplate(Template template) {
    _selectedTemplates.add(template);
    _selectedTemplatesController.add(_selectedTemplates);
  }

  void deselectTemplate(Template template) {
    _selectedTemplates.remove(template);
    _selectedTemplatesController.add(_selectedTemplates);
  }

  void _updateTemplates(List<Template> list) {
    _templates.clear();
    _templates.addAll(list?.where((template) =>
            template.expenseType == ExpenseType.values[_expenseType]) ??
        []);
    _templatesController.add(_templates);
  }

  void deleteTemplates() {
    repository.deleteTemplates(_selectedTemplatesController.value);
    _selectedTemplates.clear();
    _selectedTemplatesController.add(_selectedTemplates);
  }

  void dispose() {
    _templatesController.close();
    _selectedTemplatesController.close();

    _streamSubscriptions.forEach((s) => s.cancel());
  }
}
