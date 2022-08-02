import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parking_detection/globals.dart';
import 'package:parking_detection/screens/map_screen.dart';
import 'package:parking_detection/services/firestore_functions.dart';
import 'package:provider/provider.dart';

import 'booked_screen.dart';
import 'destination_reached_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool hasSelectedParking = false;
  bool hasReached = false;
  ParkingLoc? parkingLoc;

  void setParkingSelection(bool value) async {
    print('parkingSelection');
    value ? parkingLoc = await getUserParking() : null;
    setState(() {
      hasSelectedParking = value;
    });
  }

  void setReached(bool value) {
    setState(() {
      hasReached = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasReached && parkingLoc != null) {
      return BookedScreen(
        setReached: setReached,
        parkingLoc: parkingLoc!,
        setParkingSelection: setParkingSelection,
      );
    } else if (hasSelectedParking && parkingLoc != null) {
      return StreamProvider.value(
        value: ParkingFirestore().parkings,
        initialData: [],
        child: BookedScreen(
          setReached: setReached,
          parkingLoc: parkingLoc!,
          setParkingSelection: setParkingSelection,
        ),
      );
    } else {
      return MapView(
          setParkingSelection: setParkingSelection,
          setReached: setReached); //TODO: send both functions
    }
  }
}
