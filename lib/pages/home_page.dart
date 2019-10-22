import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Keys
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: _buildAppBar(),
        body: Container(),
    floatingActionButton: _buildFAB(),
      );

  Widget _buildAppBar() => AppBar(title: Text("Home"));
  Widget _buildFAB() => FloatingActionButton(
    child: Icon(Icons.add),
    onPressed: () {}, // TODO: FAB ACTIONS
  );
}
