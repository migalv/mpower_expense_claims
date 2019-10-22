import 'package:flutter/material.dart';

class Utils {
  void pushReplacement(BuildContext context, Widget to, {int delay = 0}) async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: delay)).then((_) => Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => to)));
    });
  }
}

final Utils utils = Utils();
