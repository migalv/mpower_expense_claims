import 'dart:async';

import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/models/template_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/sort_options.dart';
import 'package:flutter/widgets.dart';

class FilterStreamTransformer<S, T> implements StreamTransformer<S, T> {
  StreamController _controller;
  StreamSubscription _subscription;
  S _lastData;
  S _filteredData;
  Stream<S> _stream;
  final String collection;
  String sortingBy = SortOptions.CREATED_AT;
  String searchingBy = '';

  FilterStreamTransformer.broadcast({
    @required this.collection,
    @required this.sortingBy,
  }) {
    _controller =
        StreamController<T>.broadcast(onListen: _onListen, onCancel: _onCancel);
  }

  void _onListen() {
    _subscription = _stream.listen(_onData,
        onError: _controller.addError, onDone: _controller.close);
  }

  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  void refresh() {
    _filterAndSort();
    _controller.add(_filteredData);
  }

  void _onData(S data) {
    _lastData = data;
    refresh();
  }

  @override
  Stream<T> bind(Stream<S> stream) {
    this._stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return null;
  }

  void _filterAndSort() {
    if (_lastData == null) return;
    switch (collection) {
      case EXPENSE_CLAIMS_COLLECTION:
        _filteredData =
            List<ExpenseClaim>.from(_lastData as List<ExpenseClaim>) as S;
        break;
      case INVOICES_COLLECTION:
        _filteredData = List<Invoice>.from(_lastData as List<Invoice>) as S;
        break;
      case TEMPLATES_COLLECTION:
        _filteredData = List<Template>.from(_lastData as List<Template>) as S;
        break;
    }

    // Search by string
    if (searchingBy != '') {
      _filteredData = (_filteredData as List)
          .where((element) => element.description
              .toLowerCase()
              .contains(searchingBy.toLowerCase()))
          .toList() as S;
    }

    // Filter the deleted ones
    _filteredData = (_filteredData as List)
        .where((element) => element.deleted == false)
        .toList() as S;

    // Sort by
    (_filteredData as List).sort((element1, element2) {
      if (sortingBy == "") // If filtering sort by name
        return element1.description.compareTo(element2.name);
      switch (sortingBy) {
        case SortOptions.CREATED_AT:
          return element2.date.compareTo(element1.date);
        default:
          return 0;
      }
    });
  }
}
