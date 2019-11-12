import 'package:rxdart/rxdart.dart';
import 'package:expense_claims_app/repository.dart';
import 'package:rxdart/subjects.dart';

class HomeBloc {
  //
  // OUTPUT
  ValueObservable<int> get pageIndex => _pageIndexController.stream;

  // Subjects
  final _pageIndexController = BehaviorSubject<int>();

  HomeBloc({lastPageIndex = 0}) {
    _pageIndexController.add(lastPageIndex ?? 0);
  }

  //
  // INPUT
  void setPageIndex(int index) {
    _pageIndexController.add(index);
    repository.updateLastSelectedPageIndex(index);
  }

  void dispose() {
    _pageIndexController.close();
  }
}
