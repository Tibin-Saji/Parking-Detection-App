import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingLoc {
  String? address;
  String name;
  LatLng position;
  num availableSLots;
  num booked;
  List<ParkingZones>? zones;
  ParkingLoc(
      {required this.name,
      this.address,
      required this.position,
      required this.availableSLots,
      required this.booked,
      this.zones});
  static final empty = ParkingLoc(
      name: '', position: const LatLng(0.0, 0.0), availableSLots: 0, booked: 0);
}

class ParkingZones {
  String name;
  LatLng location;
  num availableSlots;
  num totalSlots;
  num booked;

  ParkingZones(
      {required this.name,
      required this.location,
      required this.availableSlots,
      required this.booked,
      required this.totalSlots});
}

class UserCustom {
  String email;
  String? name;
  String? parkingLoc;
  String? zone;
  List myBookings;
  double wallet;

  UserCustom(this.email, this.name, this.parkingLoc, this.zone, this.myBookings,
      this.wallet);

  UserCustom.fromJSON(Map<String, dynamic> map)
      : name = map['name'],
        email = map['email'],
        parkingLoc = map['parkingLoc'],
        myBookings = map['myBookings'],
        wallet = map['wallet'],
        zone = map['zone'];

  Map<String, dynamic> toJSON() => {
        'name': name,
        'email': email,
        'parkingLoc': parkingLoc,
        'zone': zone,
        'myBookings': myBookings,
        'wallet': wallet
      };
}
