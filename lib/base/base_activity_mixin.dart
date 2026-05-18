import 'package:flutter/material.dart';

mixin BaseActivityMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    debugPrint("BaseActivity → initState");
  }

  @override
  void dispose() {
    debugPrint("BaseActivity → dispose");
    super.dispose();
  }
}
