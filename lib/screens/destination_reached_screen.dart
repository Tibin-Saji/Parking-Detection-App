import 'package:flutter/material.dart';

import '../custom_widget.dart';
import '../globals.dart';

class DestinationReachedScreen extends StatefulWidget {
  DestinationReachedScreen(
      {Key? key, required this.setParkingSelection, required this.setReached})
      : super(key: key);
  Function setParkingSelection;
  Function setReached;

  @override
  State<DestinationReachedScreen> createState() =>
      _DestinationReachedScreenState();
}

class _DestinationReachedScreenState extends State<DestinationReachedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [TextCustom('hello')],
      ),
    );
  }
}
