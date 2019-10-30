import 'dart:async';

import 'package:expense_claims_app/models/expense_template_model.dart';
import 'package:rxdart/rxdart.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:rxdart/subjects.dart';

class HomeBloc {
  //
  // OUTPUT
  Stream<int> get pageIndex => _pageIndexController.stream;
  Stream<BottomSheetState> get bottomSheetState =>
      _bottomSheetStateController.stream;
  Stream<FormTemplate> get selectedFormTemplate =>
      _selectedFormTemplateController.stream;

  // Subjects
  final _pageIndexController = PublishSubject<int>();
  final _bottomSheetStateController = BehaviorSubject<BottomSheetState>();
  final _selectedFormTemplateController = BehaviorSubject<FormTemplate>();

  HomeBloc() {
    repository.loadSettings();
  }

  //
  // INPUT
  void setPageIndex(int index) {
    _pageIndexController.add(index);
  }

  void setBottomSheetState(BottomSheetState state) {
    _bottomSheetStateController.add(state);
  }

  void selectFormTemplate(FormTemplate formTemplate) {
    _selectedFormTemplateController.add(formTemplate);
  }

  void dispose() {
    _pageIndexController.close();
    _bottomSheetStateController.close();
    _selectedFormTemplateController.close();
  }
}

enum BottomSheetState {
  CLOSED,
  TEMPLATES,
  FORM,
}
