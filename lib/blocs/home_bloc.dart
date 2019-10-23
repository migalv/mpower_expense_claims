import 'package:rxdart/subjects.dart';

class HomeBloc {
  //
  // OUTPUT
  Stream<int> get pageIndex => _pageIndexController.stream;

  // Subjects
  final _pageIndexController = PublishSubject<int>();

  //
  // INPUT
  void setPageIndex(int index) {
    _pageIndexController.add(index);
  }

  void dispose() {
    _pageIndexController.close();
  }
}
