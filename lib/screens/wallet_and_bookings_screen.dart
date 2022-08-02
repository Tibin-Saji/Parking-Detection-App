import 'package:flutter/material.dart';
import 'package:parking_detection/globals.dart';
import 'package:parking_detection/screens/booked_secondary_screen.dart';
import 'package:parking_detection/services/firestore_functions.dart';
import 'package:provider/provider.dart';

import '../custom_widget.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  UserCustom? _userDetails;
  double walletCash = 0;

  _initialFunc() async {
    _userDetails = await getUserDetails();
    walletCash = _userDetails!.wallet;
    setState(() {});
  }

  @override
  void initState() {
    _initialFunc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment(0, 0),
        end: Alignment.topRight,
        colors: [Color(0xff181822), Color(0xff4e515a)],
      )),
      child: Scaffold(
        appBar: AppBar(
          title: TextCustom(
            'Wallet',
            color: Color(0xffbfbfbf),
          ),
          backgroundColor: Colors.transparent,
          centerTitle: true,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
            child: _userDetails == null
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(height: 150),
                      TextCustom(
                        'Balance : ',
                        size: 30,
                        color: Color(0xffaa837d),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextCustom(
                        '₹${walletCash.toString()}',
                        color: Color(0xffbfbfbf),
                        // color: Color(0xffe8b923),
                        size: 60,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      TextCustom(
                        'Add cash : ',
                        color: Color(0xffaa837d),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButtonCustom(
                              color: Color(0xffca9c95),
                              onPressed: () {
                                walletCash += 50;
                                updateWallet(walletCash);
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextCustom(
                                  'Add 50',
                                  size: 20,
                                  color: Colors.black,
                                ),
                              )),
                          ElevatedButtonCustom(
                              color: Color(0xffca9c95),
                              onPressed: () {
                                walletCash += 100;
                                updateWallet(walletCash);
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextCustom(
                                  'Add 100',
                                  size: 20,
                                  color: Colors.black,
                                ),
                              )),
                          ElevatedButtonCustom(
                              color: Color(0xffca9c95),
                              onPressed: () {
                                walletCash += 200;
                                updateWallet(walletCash);
                                setState(() {});
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextCustom(
                                  'Add 200',
                                  size: 20,
                                  color: Colors.black,
                                ),
                              )),
                        ],
                      )
                    ],
                  )),
      ),
    );
  }
}

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({Key? key}) : super(key: key);

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  UserCustom? _userDetails;

  _initialFunc() async {
    _userDetails = await getUserDetails();
    setState(() {});
  }

  @override
  void initState() {
    _initialFunc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment(0, 0),
        end: Alignment.topRight,
        colors: [Color(0xff181822), Color(0xff4e515a)],
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: TextCustom(
            "My Bookings",
            color: Color(0xffbfbfbf),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
              child: _userDetails != null && _userDetails!.myBookings.length > 0
                  ? ListView.builder(
                      itemCount: _userDetails!.myBookings.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // StreamProvider.value(
                            //   initialData: [],
                            //   value: ParkingFirestore().parkings,
                            //   child: BookedSecondaryScreen(
                            //       myBooking: _userDetails!.myBookings[index]),
                            // );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookedSecondaryScreen(
                                        myBooking:
                                            _userDetails!.myBookings[index])));
                          },
                          child: Card(
                              color: Colors.transparent,
                              margin: EdgeInsets.symmetric(horizontal: 64),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 8),
                                child: Column(
                                  children: [
                                    TextCustom(
                                      _userDetails!.myBookings[index]
                                          .split(':')[0],
                                      align: TextAlign.center,
                                      size: 16,
                                      color: Color(0xff70616e),
                                    ),
                                    TextCustom(
                                      _userDetails!.myBookings[index]
                                          .split(':')[1],
                                      align: TextAlign.center,
                                      size: 18,
                                      // color: Color(0xff40383e),
                                      color: Color(0xffbfbfbf),
                                    ),
                                  ],
                                ),
                              )),
                        );
                      })
                  : TextCustom(
                      "You don't have any past bookings",
                      color: Color(0xffbfbfbf),
                    )),
        ),
      ),
    );
  }
}
