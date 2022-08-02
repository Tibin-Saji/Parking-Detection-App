import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widget.dart';
import '../globals.dart';
import '../services/firestore_functions.dart';

class BookedScreen extends StatefulWidget {
  BookedScreen(
      {Key? key,
      required this.setParkingSelection,
      required this.setReached,
      required this.parkingLoc})
      : super(key: key);
  Function setParkingSelection;
  Function setReached;
  final ParkingLoc parkingLoc;

  @override
  State<BookedScreen> createState() => _BookedScreenState();
}

class _BookedScreenState extends State<BookedScreen> {
  ParkingFirestore _parkingFirestore = ParkingFirestore();
  ParkingLoc? parkingLoc;
  ParkingZones? zone;
  late UserCustom _userCustom;
  String? zoneName;
  bool isBooked = false;

  void getData() {
    parkingLoc = widget.parkingLoc;
    _parkingFirestore.parkings.listen((event) {
      setState(() {
        parkingLoc = event[event.indexOf(widget.parkingLoc)];
      });
    });
  }

  //TODO: make a function to find the index of the zone in the parkingLoc
  void getZone(String zoneName) {
    zone = parkingLoc!.zones!.firstWhere((element) => element.name == zoneName);
  }

  Future initialFunc() async {
    parkingLoc = widget.parkingLoc;
    _userCustom = await getUserDetails();
    zoneName = _userCustom.zone;
    zoneName != null ? getZone(zoneName!) : null;
    setState(() {});
  }

  @override
  void initState() {
    initialFunc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getData();
    var parkingList = Provider.of<List<ParkingLoc>>(context);
    try {
      parkingLoc = parkingList[parkingList.indexOf(widget.parkingLoc)];
    } catch (e) {}
    return zone == null
        ? Center(child: CircularProgressIndicator())
        : Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment(0, 0),
              end: Alignment.topRight,
              colors: [Color(0xff181822), Color(0xff4e515a)],
            )),
            child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16),
                  child: ListView(
                    children: [
                      Center(
                        child: TextCustom(
                          parkingLoc!.name,
                          size: 40,
                          color: Color(0xff93CCEA),
                        ),
                      ),
                      Center(
                        child: TextCustom(
                          zone!.name,
                          size: 30,
                          color: Color(0xff20a7db),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextCustom(
                        'Total Free Slots : ${(zone!.availableSlots - zone!.booked).toString()}',
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Image.network(
                            "http://api.qrserver.com/v1/create-qr-code/?data=${_userCustom.email}-${_userCustom.zone}&size=200x200"),
                      ),
                      ElevatedButtonCustom(
                          onPressed: () async {
                            await updateParkingBooking(parkingLoc!.name,
                                parkingLoc!.zones!.indexOf(zone!), false);
                            widget.setParkingSelection(false);
                            // widget.setReached(false);
                            //TODO: navigate to the map screen when clicked
                          },
                          color: Colors.white,
                          child: TextCustom('Cancel Booking')),
                      ElevatedButtonCustom(
                          onPressed: () async {
                            await updateParkingBooking(parkingLoc!.name,
                                parkingLoc!.zones!.indexOf(zone!), false);
                            widget.setParkingSelection(false);
                            // widget.setReached(false);
                            //TODO: navigate to the map screen when clicked
                          },
                          color: Colors.white,
                          child: TextCustom('Reached')),
                    ],
                  ),
                )),
          );
  }
}
