import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../custom_widget.dart';
import '../globals.dart';
import '../services/firestore_functions.dart';

class BookedSecondaryScreen extends StatefulWidget {
  BookedSecondaryScreen({Key? key, required this.myBooking}) : super(key: key);
  // Function setParkingSelection;
  // Function setReached;
  String myBooking;
  // final ParkingLoc parkingLoc;

  @override
  State<BookedSecondaryScreen> createState() => _BookedSecondaryScreenState();
}

class _BookedSecondaryScreenState extends State<BookedSecondaryScreen> {
  ParkingFirestore _parkingFirestore = ParkingFirestore();
  ParkingLoc? parkingLoc;
  ParkingZones? zone;
  late UserCustom _userCustom;
  String? zoneName;
  String? parkingName;

  // bool isBooked = false;

  // void getData() {
  //   parkingLoc = widget.parkingLoc;
  //   _parkingFirestore.parkings.listen((event) {
  //     setState(() {
  //       parkingLoc = event[event.indexOf(widget.parkingLoc)];
  //     });
  //   });
  // }

  //TODO: make a function to find the index of the zone in the parkingLoc
  void getZone(String zoneName) {
    zone = parkingLoc!.zones!.firstWhere((element) => element.name == zoneName);
  }

  Future initialFunc() async {
    // parkingLoc = widget.parkingLoc;
    var combinedParkingDetails = widget.myBooking.split(':');
    var parkingDetails = combinedParkingDetails[1].split('-');
    parkingName = parkingDetails[0].trim();
    zoneName = parkingDetails[1].trim();
    if (mounted) {
      parkingName != null
          ? parkingLoc = await getParkingLoc(parkingName!)
          : null;

      _userCustom = await getUserDetails();

      zoneName != null ? getZone(zoneName!) : null;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // getData();
    // var parkingList = Provider.of<List<ParkingLoc>>(context);
    initialFunc();

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
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                ),
                backgroundColor: Colors.transparent,
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24.0, horizontal: 16),
                  child: Column(
                    children: [
                      Center(
                        child: TextCustom(
                          parkingLoc!.name,
                          color: Color(0xff93CCEA),
                          size: 40,
                        ),
                      ),
                      Center(
                        child: TextCustom(
                          zone!.name,
                          color: Color(0xff20a7db),
                          size: 30,
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextCustom(
                        'Total Free Slots : ${(zone!.availableSlots - zone!.booked).toString()}',
                        color: Colors.white,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Image.network(
                            "http://api.qrserver.com/v1/create-qr-code/?data=${_userCustom.email}-${_userCustom.zone}&size=200x200"),
                      ),
                      // ElevatedButtonCustom(
                      //     onPressed: () async {
                      //       await updateParkingBooking(parkingLoc!.name,
                      //           parkingLoc!.zones!.indexOf(zone!), false);
                      //       widget.setParkingSelection(false);
                      //       // widget.setReached(false);
                      //     },
                      //     color: Colors.white,
                      //     child: TextCustom('Cancel Booking')),
                    ],
                  ),
                )),
          );
  }
}
