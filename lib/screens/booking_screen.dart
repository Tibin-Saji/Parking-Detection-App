import 'package:flutter/material.dart';
import 'package:parking_detection/globals.dart';
import 'package:parking_detection/services/firestore_functions.dart';
import 'package:provider/provider.dart';

import '../custom_widget.dart';

class BookingScreen extends StatefulWidget {
  BookingScreen({Key? key, required this.parkingIndex}) : super(key: key);
  final int parkingIndex;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  ParkingLoc? parkingLoc = null;

  int bookedZone = -1;

  // void getData() {
  //   Future.delayed(const Duration(milliseconds: 500), () {
  //     _parkingFirestore.parkings.listen((event) {
  //       parkingLoc = event[widget.parkingIndex];
  //       setState(() {});
  //     });
  //   });
  // }

  Widget ZoneCard(ParkingZones zone) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(zone.name,
                    // color: Color(0xff874741)
                    // color: Color(0xff93CCEA)),
                    color: Color(0xff20a7db)),
                Row(
                  children: [
                    TextCustom(
                      'Free Slots : ',
                      size: 18,
                      color: Color(0xffbfbfbf),
                    ),
                    TextCustom(
                      (zone.availableSlots.toInt() - zone.booked.toInt())
                          .toString(),
                      color: Color(0xffbfbfbf),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
            ElevatedButtonCustom(
              nullColor: Color(0xffCCCCCC),
              onPressed:
                  bookedZone == -1 && (zone.availableSlots - zone.booked) > 0
                      ? () {
                          updateParkingBooking(parkingLoc!.name,
                              parkingLoc!.zones!.indexOf(zone), true);
                          setState(() {
                            bookedZone = parkingLoc!.zones!.indexOf(zone);
                          });
                        }
                      : null,
              child: bookedZone == -1
                  ? TextCustom(
                      'Book Here',
                      size: 20,
                      color: Colors.black,
                    )
                  : bookedZone == parkingLoc!.zones!.indexOf(zone)
                      ? Row(
                          children: [
                            Icon(Icons.check),
                            TextCustom(
                              'Booked',
                              size: 20,
                            )
                          ],
                        )
                      : TextCustom(
                          'Book',
                          size: 20,
                        ),
              color: Color(0xffca9c95),
              // color: Color(0xffcfecf7),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   getData();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // use WidgetsBinding.instance.addPostFrameCallBack((_){})
    // parkingLoc = parkingList[widget.parkingIndex];
    var parkingList = Provider.of<List<ParkingLoc>>(context);
    try {
      parkingLoc = parkingList[widget.parkingIndex];
    } catch (e) {}
    return parkingList.isEmpty
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
              begin: Alignment(0, 0),
              end: Alignment.topRight,
              colors: [Color(0xff181822), Color(0xff4e515a)],
            )),
            child: Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  title: TextCustom(
                    'Location',
                    color: Color(0xffbfbfbf),
                  ),
                  centerTitle: true,
                ),
                backgroundColor: Colors.transparent,
                body: parkingLoc == null
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Center(
                              child: TextCustom(
                                parkingLoc!.name,
                                size: 50,
                                color: Color(0xff93CCEA),
                                weight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            TextCustom(
                              'Total Free Slots : ${(parkingLoc!.availableSLots - parkingLoc!.booked).toString()}',
                              color: Color(0xffbfbfbf),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            parkingLoc!.zones != null
                                ? TextCustom(
                                    'Zones :',
                                    color: Color(0xffbfbfbf),
                                  )
                                : const SizedBox.shrink(),
                            parkingLoc!.zones != null
                                ? Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(15, 8, 0, 8),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.42,
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: parkingLoc!.zones!.length,
                                          itemBuilder: (context, index) {
                                            return ZoneCard(
                                                parkingLoc!.zones![index]);
                                          }),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: ElevatedButtonCustom(
                                  onPressed: () async {
                                    if (bookedZone != -1) {
                                      await updateParkingBooking(
                                          parkingLoc!.name, bookedZone, false);
                                    }
                                    bookedZone = -1;
                                    Navigator.of(context).pop([null, 0]);
                                  },
                                  color: Colors.white,
                                  child: TextCustom('Cancel')),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: ElevatedButtonCustom(
                                  onPressed: bookedZone != -1
                                      ? () {
                                          Navigator.of(context).pop([
                                            parkingLoc!.zones![bookedZone],
                                            1
                                          ]);
                                        }
                                      : null,
                                  color: Colors.red,
                                  nullColor: Color(0xffbfbfbf),
                                  child: TextCustom(
                                    'Get Directions',
                                  )),
                            ),
                            Visibility(
                              visible: bookedZone != -1,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0),
                                child: ElevatedButtonCustom(
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          [parkingLoc!.zones![bookedZone], 2]);
                                    },
                                    color: Colors.white,
                                    child: TextCustom('Stay In The App')),
                              ),
                            )
                          ],
                        ),
                      )),
          );
  }
}
