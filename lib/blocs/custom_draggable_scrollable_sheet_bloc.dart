import 'dart:async';

class TestLolBloc {
  //
  // OUTPUT
  Stream<int> get index => _indexController.stream;

  // Subjects
  final _indexController = StreamController<int>();

  void setIndex(int index) {
    _indexController.add(index);
  }

  void dispose() {
    _indexController.close();
  }
}
