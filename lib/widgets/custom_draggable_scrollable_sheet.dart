import 'package:expense_claims_app/bloc_provider.dart';
import 'package:expense_claims_app/blocs/custom_draggable_scrollable_sheet_bloc.dart';
import 'package:flutter/material.dart';

class TestLol extends StatelessWidget {
  final List<Widget> _widgets;

  TestLol(this._widgets);

  @override
  Widget build(BuildContext context) {
    final TestLolBloc bloc = Provider.of<TestLolBloc>(context);

    return StreamBuilder<int>(
      initialData: 0,
      stream: bloc.index,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.data == null
            ? Container()
            : AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: _widgets[snapshot.data],
              );
      },
    );
  }
}
