import 'dart:async';

import 'package:expense_claims_app/filter_stream_transformer.dart';
import 'package:expense_claims_app/models/expense_claim_model.dart';
import 'package:expense_claims_app/models/expense_model.dart';
import 'package:expense_claims_app/models/invoice_model.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:expense_claims_app/sort_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

/// Expenses Bloc
///
/// Bloc with the logic for both lists of expenses and invoices.const
class ExpensesBloc {
  StreamTransformer _filterStreamTransformer;
  final ExpenseType expenseType;
  Stream<List<Expense>> _stream;

  //
  // OUTPUT
  Stream<List> get expenses => _stream;
  ValueObservable<bool> get isSearching => _isSearching.stream;

  //
  // INPUT
  Sink<String> get searchBy => _searchController.sink;

  //
  // SUBJECTS
  final _searchController = BehaviorSubject<String>();
  final _isSearching = BehaviorSubject<bool>();

  //
  // SUBSCRIPTIONS
  List<StreamSubscription> _streamSubscriptions = [];

  ExpensesBloc({@required this.expenseType}) {
    switch (expenseType) {
      case ExpenseType.EXPENSE_CLAIM:
        _filterStreamTransformer = FilterStreamTransformer<List<ExpenseClaim>,
            List<ExpenseClaim>>.broadcast(
          collection: EXPENSE_CLAIMS_COLLECTION,
          sortingBy: SortOptions.CREATED_AT,
        );
        _stream = repository.expenseClaims.transform(_filterStreamTransformer);
        break;
      case ExpenseType.INVOICE:
        _filterStreamTransformer =
            FilterStreamTransformer<List<Invoice>, List<Invoice>>.broadcast(
          collection: INVOICES_COLLECTION,
          sortingBy: SortOptions.CREATED_AT,
        );
        _stream = repository.invoices.transform(_filterStreamTransformer);
        break;
    }
    _listenToSearchChanges();
  }

  void startSearch(bool isSearching) {
    _isSearching.add(isSearching);

    // Reset the search term
    (_filterStreamTransformer as FilterStreamTransformer).searchingBy = '';
    (_filterStreamTransformer as FilterStreamTransformer).refresh();
  }

  void _listenToSearchChanges() {
    _streamSubscriptions.add(_searchController.listen((String searchTerm) {
      (_filterStreamTransformer as FilterStreamTransformer).searchingBy =
          searchTerm;
      (_filterStreamTransformer as FilterStreamTransformer).refresh();
    }));
  }

  void dispose() {
    _searchController.close();
    _isSearching.close();
    _streamSubscriptions.forEach((s) => s.cancel());
  }
}
