import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parking_detection/globals.dart';

Future addUser(String email) async {
  var _authUser = FirebaseAuth.instance.currentUser;
  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  var doc = await ref.doc(email).get();

  if (!doc.exists) {
    UserCustom user =
        UserCustom(email, _authUser?.displayName, '', '', [], 0.0);
    ref.doc(email).set(user.toJSON());
  }
}

Future<ParkingLoc> getUserParking() async {
  var _authUser = FirebaseAuth.instance.currentUser;
  CollectionReference ref = FirebaseFirestore.instance.collection('users');

  var doc = await ref.doc(_authUser?.email).get();
  var parkingName = doc['parkingLoc'];

  var parkingQueryDoc = await FirebaseFirestore.instance
      .collection('parking-slot')
      .where('Name', isEqualTo: parkingName)
      .get();
  doc = parkingQueryDoc.docs.first;

  var zones = doc['Zones'];
  List<ParkingZones> zonesList = [];
  for (var zone in zones) {
    zonesList.add(ParkingZones(
        name: zone['otherName'],
        location: LatLng(zone['Location'].latitude, zone['Location'].longitude),
        availableSlots: zone['Free'],
        booked: zone['Booked'],
        totalSlots: zone['Total Parking']));
  }
  return ParkingLoc(
      name: doc['Name'] ?? '',
      availableSLots: doc['Free'] ?? 0,
      position: LatLng(doc['Location'].latitude, doc['Location'].longitude),
      booked: doc['Booked'],
      zones: zonesList);
}

Future updateWallet(double value) async {
  var _authUser = FirebaseAuth.instance.currentUser;
  var doc =
      FirebaseFirestore.instance.collection('users').doc(_authUser?.email);

  doc.update({'wallet': value});
}

Future<ParkingLoc> getParkingLoc(String parkingName) async {
  var parkingQueryDoc = await FirebaseFirestore.instance
      .collection('parking-slot')
      .where('Name', isEqualTo: parkingName)
      .get();
  var doc = parkingQueryDoc.docs.first;

  var zones = doc['Zones'];
  List<ParkingZones> zonesList = [];
  for (var zone in zones) {
    zonesList.add(ParkingZones(
        name: zone['otherName'],
        location: LatLng(zone['Location'].latitude, zone['Location'].longitude),
        availableSlots: zone['Free'],
        booked: zone['Booked'],
        totalSlots: zone['Total Parking']));
  }
  return ParkingLoc(
      name: doc['Name'] ?? '',
      availableSLots: doc['Free'] ?? 0,
      position: LatLng(doc['Location'].latitude, doc['Location'].longitude),
      booked: doc['Booked'],
      zones: zonesList);
}

Future<UserCustom> getUserDetails() async {
  var _authUser = FirebaseAuth.instance.currentUser;
  DocumentSnapshot doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(_authUser?.email)
      .get();

  return UserCustom(doc['email'], doc['name'], doc['parkingLoc'], doc['zone'],
      doc['myBookings'], doc['wallet']);
}

Future updateMyBookings(String booking) async {
  var _authUser = FirebaseAuth.instance.currentUser;
  var doc =
      FirebaseFirestore.instance.collection('users').doc(_authUser?.email);

  doc.update({
    'myBookings': FieldValue.arrayUnion([booking])
  });
}

Future updateParkingBooking(
    String parkingName, int zoneIndex, bool isAdding) async {
  var _authUser = FirebaseAuth.instance.currentUser;
  DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(_authUser?.email);

  // var userDoc = await userDocRef.get();
  var parkingQueryDoc = await FirebaseFirestore.instance
      .collection('parking-slot')
      .where('Name', isEqualTo: parkingName)
      .get();
  var parkingDoc = parkingQueryDoc.docs.first;

  int booked = parkingDoc['Booked'];
  var zoneArray = parkingDoc['Zones'];

  if (isAdding) {
    ++booked;
    await userDocRef.update({
      'parkingLoc': parkingDoc['Name'],
      'zone': zoneArray[zoneIndex]['otherName']
    });
    zoneArray[zoneIndex]['Booked'] += 1;
  } else {
    --booked;
    await userDocRef.update({'parkingLoc': '', 'zone': ''});
    zoneArray[zoneIndex]['Booked'] -= 1;
  }

  await FirebaseFirestore.instance
      .collection('parking-slot')
      .doc(parkingDoc.id)
      .update({'Booked': booked, 'Zones': zoneArray});
}

Future updateParkingBookingName(
    String parkingName, String zoneName, bool isAdding) async {
  var _authUser = FirebaseAuth.instance.currentUser;
  DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('users').doc(_authUser?.email);

  // var userDoc = await userDocRef.get();
  var parkingQueryDoc = await FirebaseFirestore.instance
      .collection('parking-slot')
      .where('Name', isEqualTo: parkingName)
      .get();
  var parkingDoc = parkingQueryDoc.docs.first;

  int booked = parkingDoc['Booked'];
  var zoneArray = parkingDoc['Zones'];

  if (isAdding) {
    ++booked;
    await userDocRef.update({
      'parkingLoc': parkingDoc['Name'],
      'zone': zoneArray[zoneIndex(zoneName, zoneArray)]['otherName']
    });
    zoneArray[zoneIndex(zoneName, zoneArray)]['Booked'] += 1;
  } else {
    --booked;
    await userDocRef.update({'parkingLoc': '', 'zone': ''});
    zoneArray[zoneIndex(zoneName, zoneArray)]['Booked'] -= 1;
  }

  await FirebaseFirestore.instance
      .collection('parking-slot')
      .doc(parkingDoc.id)
      .update({'Booked': booked, 'Zones': zoneArray});
}

int zoneIndex(String zoneName, List zoneArray) {
  for (int i = 0; i < zoneArray.length; i++) {
    if (zoneArray[i]['otherName'] == zoneName) {
      return i;
    }
  }
  return -1;
}

class ParkingFirestore {
  final CollectionReference ref =
      FirebaseFirestore.instance.collection("parking-slot");

  List<ParkingLoc> _ParkingListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        var docMap = doc.data() as Map<String, dynamic>;
        var zones = docMap['Zones'];
        List<ParkingZones> zonesList = [];
        for (var zone in zones) {
          // print('name : ' + zone['otherName'].runtimeType.toString());
          // print('location : ' + zone['Location'].runtimeType.toString());
          // print('location : ' + zone['Location'].runtimeType.toString());
          // print('Free : ' + zone['Free'].runtimeType.toString());
          // print('Booked : ' + zone['Booked'].runtimeType.toString());
          // print('Total Parking : ' +
          //     zone['Total Parking'].runtimeType.toString());
          zonesList.add(ParkingZones(
              name: zone['otherName'],
              location:
                  LatLng(zone['Location'].latitude, zone['Location'].longitude),
              availableSlots: zone['Free'],
              booked: zone['Booked'],
              totalSlots: zone['Total Parking']));
        }
        return ParkingLoc(
            name: docMap['Name'] ?? '',
            address: docMap['Address'],
            availableSLots: docMap['Free'] ?? 0,
            position:
                LatLng(docMap['Location'].latitude, doc['Location'].longitude),
            booked: docMap['Booked'],
            zones: zonesList);
      }).toList();
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  Stream<List<ParkingLoc>> get parkings {
    return ref.snapshots().map(_ParkingListFromSnapshot);
  }
}
