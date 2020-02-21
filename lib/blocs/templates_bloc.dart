import 'dart:async';

import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class TemplatesBloc {
  List<StreamSubscription> _streamSubscriptions = [];
  List<Template> _selectedTemplates;
  final ExpenseType expenseType;

  //
  //  OUTPUT
  Stream<List<Template>> get templates => repository.templates.transform(
      StreamTransformer<List<Template>, List<Template>>.fromHandlers(
          handleData: _filterTemplates));
  ValueObservable<List<Template>> get selectedTemplates =>
      _selectedTemplatesController.stream;

  // Subjects
  final _selectedTemplatesController = BehaviorSubject<List<Template>>();

  TemplatesBloc({@required this.expenseType}) {
    _selectedTemplates = [];
  }

  void selectTemplate(Template template) {
    _selectedTemplates.add(template);
    _selectedTemplatesController.add(_selectedTemplates);
  }

  void deselectTemplate(Template template) {
    _selectedTemplates.remove(template);
    _selectedTemplatesController.add(_selectedTemplates);
  }

  void deleteTemplates() {
    repository.deleteTemplates(_selectedTemplatesController.value);
    _selectedTemplates.clear();
    _selectedTemplatesController.add(_selectedTemplates);
  }

  void _filterTemplates(
      List<Template> templates, EventSink<List<Template>> sink) {
    List<Template> filteredTemplates = templates
        .where((template) => template.expenseType == expenseType)
        .toList();
    sink.add(filteredTemplates);
  }

  void dispose() {
    _selectedTemplatesController.close();

    _streamSubscriptions.forEach((s) => s.cancel());
  }
}
