import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_geocoding/google_geocoding.dart' as GeoCoder;
// import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart'
    as GPlaces; // both location and google_place has Location in it
import 'package:location/location.dart';
import 'package:parking_detection/globals.dart';
import 'package:parking_detection/notification.dart';
import 'package:parking_detection/screens/booking_screen.dart';
import 'package:parking_detection/screens/wallet_and_bookings_screen.dart';

import 'package:parking_detection/services/constants.dart';
import 'package:parking_detection/services/firestore_functions.dart';
import 'package:parking_detection/services/google_sign_in_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_widget.dart';

//TODO: add notification to pop up when the person reaches the location or when the selected parking is almost filled

class MapView extends StatefulWidget {
  MapView(
      {Key? key, required this.setParkingSelection, required this.setReached})
      : super(key: key);
  Function setParkingSelection;
  Function setReached;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final _user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;

  int selectedParkingIndex = -1;
  bool hasSelectedParking = false;
  bool hasReached = false;

  late GoogleMapController mapController;

  LatLng _currentPosition = const LatLng(0, 0);

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _destinationValue = '';
  LatLng _destinationPos = const LatLng(0, 0);

  LatLng? _zonePos = const LatLng(0, 0);

  bool showRoute = false;

  String? _placeDistance;

  Set<Marker> markers = {};

  Set<ParkingLoc> parkLoc = {};

  // late PolylinePoints polylinePoints;
  // Map<PolylineId, Polyline> polylines = {};
  // List<LatLng> polylineCoordinates = [];

  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  late GPlaces.GooglePlace googlePlace;
  List<GPlaces.AutocompletePrediction> predictions = [];
  Timer? _debounce;
  bool showPlacesMenu = false;

  late GeoCoder.GoogleGeocoding geocoder;

  bool hasShownLowParkingNotif = false;

  bool inVicinity(LatLng start, LatLng? end) {
    if (_zonePos == null) {
      print('extra line');
      return false;
    }
    if (start.longitude <= end!.longitude + 0.0001 &&
        start.longitude >= end.longitude - 0.0001 &&
        start.latitude <= end.latitude + 0.0002 &&
        start.latitude >= end.latitude - 0.0002) return true;
    return false;
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    Location location = Location();

    var locationData = await location.getLocation();
    var userDetails = await getUserDetails();
    _currentPosition =
        LatLng(locationData.latitude ?? 0.0, locationData.longitude ?? 0.0);
    // log(_currentPosition.toString());

    location.onLocationChanged.listen((newLoc) {
      _currentPosition = LatLng(
        newLoc.latitude!,
        newLoc.longitude!,
      );
      if (inVicinity(_currentPosition, _zonePos)) {
        hasReached = true;
        widget.setReached(true);
        //TODO: remove booking
        updateParkingBookingName(
            userDetails.parkingLoc!, userDetails.zone!, false);
        NotificationApi.showNotification(
            id: 1,
            title: 'Reached Location',
            body: '''Seems like you have reached the parking area.
           Let us guide you to your parking.''');
      }
    });
  }

  // Method for calculating the distance between two places

  Future<bool> _setDestination() async {
    try {
      Marker destinationMarker = Marker(
          markerId: MarkerId(_destinationPos.toString()),
          position: _destinationPos,
          infoWindow: InfoWindow(
            title: _destinationValue,
          ),
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration.empty, 'assets/DestinationPinNew.png'));

      markers.add(destinationMarker);

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: _destinationPos, zoom: 15)),
      );
      return true;
    } catch (e) {
      log(e.toString());
      return false;
    }
  }

  void _markParkings(List<ParkingLoc> list) async {
    for (int i = 0; i < list.length; i++) {
      var parking = list[i];
      print('*************************************************************');
      markers.add(Marker(
          markerId: MarkerId(parking.position.toString()),
          position: list[i].position,
          infoWindow: InfoWindow(title: parking.name, snippet: parking.address),
          icon: await BitmapDescriptor.fromAssetImage(
              ImageConfiguration.empty, 'assets/ParkingPinNewWhite.png'),
          onTap: () async {
            selectedParkingIndex = i;
            // res is a array of 2 elements. First one is ParkingZone and second is value
            var res = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StreamProvider<List<ParkingLoc>>.value(
                        child: BookingScreen(
                          parkingIndex: selectedParkingIndex,
                        ),
                        initialData: const [],
                        value: ParkingFirestore().parkings,
                      )),
            );
            int value = res[1];
            ParkingZones? zone = res[0];
            if (zone != null) {
              _zonePos = zone.location;
              var now = DateTime.now();
              var dateString =
                  "${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}";
              updateMyBookings("$dateString : ${parking.name}-${zone.name}");
              widget.setParkingSelection(true);
              if (value == 1) {
                widget.setParkingSelection(true);
                final Uri url = Uri.parse(
                    "https://www.google.com/maps/dir/?api=1&origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=${zone.location.latitude},${zone.location.longitude}&travelmode=driving");
                await launchUrl(url, mode: LaunchMode.externalApplication);
              }
            }
            // hasSelectedParking = true;
          }));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    var parkingLocations = Provider.of<List<ParkingLoc>>(context);
    print('parking' + parkingLocations.length.toString());
    _markParkings(parkingLocations);

    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment(0, 0),
        end: Alignment.topRight,
        colors: [Color(0xff181822), Color(0xff4e515a)],
      )),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: TextCustom(
            'PARKED',
            color: Color(0xffbfbfbf),
            size: 24,
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            PopupMenuButton(
              color: Color(0xffc1c1c1),
              icon: Padding(
                padding: const EdgeInsets.all(1.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: _user!.photoURL != null
                        ? Image.network(
                            _user!.photoURL!,
                          )
                        : const Icon(Icons.person)),
              ),
              itemBuilder: (context) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: TextCustom(
                    'Logout',
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                  onTap: () {
                    final provider = Provider.of<GoogleSignInProvider>(context,
                        listen: false);
                    provider.googleLogOut();
                  },
                ),
                PopupMenuItem(
                  child: TextCustom(
                    'Wallet',
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                  value: 1,
                ),
                PopupMenuItem(
                  child: TextCustom(
                    'My Bookings',
                    size: 16,
                    weight: FontWeight.w600,
                  ),
                  value: 2,
                )
              ],
              onSelected: (result) {
                if (result == 1) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WalletScreen()));
                } else if (result == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MyBookingsScreen()));
                }
              },
            ),
          ],
        ),
        body: isLoading
            ? Center(
                child: TextCustom(
                'Give us a second to find you',
                color: Color(0xffbfbfbf),
              ))
            : Stack(
                children: <Widget>[
                  // Map View
                  GoogleMap(
                    markers: markers,
                    initialCameraPosition:
                        CameraPosition(target: _currentPosition, zoom: 8),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    mapType: MapType.normal,
                    zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    // polylines: Set<Polyline>.of(polylines.values),
                    onMapCreated: (GoogleMapController controller) {
                      setState(() {
                        mapController = controller;
                        mapController.setMapStyle(
                            '[ { "elementType": "geometry", "stylers": [ { "color": "#1d2c4d" } ] }, { "elementType": "labels.text.fill", "stylers": [ { "color": "#8ec3b9" } ] }, { "elementType": "labels.text.stroke", "stylers": [ { "color": "#1a3646" } ] }, { "featureType": "administrative.country", "elementType": "geometry.stroke", "stylers": [ { "color": "#4b6878" } ] }, { "featureType": "administrative.land_parcel", "elementType": "labels.text.fill", "stylers": [ { "color": "#64779e" } ] }, { "featureType": "administrative.province", "elementType": "geometry.stroke", "stylers": [ { "color": "#4b6878" } ] }, { "featureType": "landscape.man_made", "elementType": "geometry.stroke", "stylers": [ { "color": "#334e87" } ] }, { "featureType": "landscape.natural", "elementType": "geometry", "stylers": [ { "color": "#023e58" } ] }, { "featureType": "poi", "elementType": "geometry", "stylers": [ { "color": "#283d6a" } ] }, { "featureType": "poi", "elementType": "labels.text.fill", "stylers": [ { "color": "#6f9ba5" } ] }, { "featureType": "poi", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1d2c4d" } ] }, { "featureType": "poi.park", "elementType": "geometry.fill", "stylers": [ { "color": "#023e58" } ] }, { "featureType": "poi.park", "elementType": "labels.text.fill", "stylers": [ { "color": "#3C7680" } ] }, { "featureType": "road", "elementType": "geometry", "stylers": [ { "color": "#304a7d" } ] }, { "featureType": "road", "elementType": "labels.text.fill", "stylers": [ { "color": "#98a5be" } ] }, { "featureType": "road", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1d2c4d" } ] }, { "featureType": "road.highway", "elementType": "geometry", "stylers": [ { "color": "#2c6675" } ] }, { "featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [ { "color": "#255763" } ] }, { "featureType": "road.highway", "elementType": "labels.text.fill", "stylers": [ { "color": "#b0d5ce" } ] }, { "featureType": "road.highway", "elementType": "labels.text.stroke", "stylers": [ { "color": "#023e58" } ] }, { "featureType": "transit", "elementType": "labels.text.fill", "stylers": [ { "color": "#98a5be" } ] }, { "featureType": "transit", "elementType": "labels.text.stroke", "stylers": [ { "color": "#1d2c4d" } ] }, { "featureType": "transit.line", "elementType": "geometry.fill", "stylers": [ { "color": "#283d6a" } ] }, { "featureType": "transit.station", "elementType": "geometry", "stylers": [ { "color": "#3a4762" } ] }, { "featureType": "water", "elementType": "geometry", "stylers": [ { "color": "#0e1626" } ] }, { "featureType": "water", "elementType": "labels.text.fill", "stylers": [ { "color": "#4e6d70" } ] } ]');
                      });
                    },
                  ),
                  // Show zoom buttons
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color: Color(0xffaa837d), // button color
                              child: InkWell(
                                splashColor: Color(0xff723c36), // inkwell color
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.add),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipOval(
                            child: Material(
                              color: Color(0xffaa837d), // button color
                              child: InkWell(
                                splashColor: Color(0xff723c36), // inkwell color
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.remove),
                                ),
                                onTap: () {
                                  mapController.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Show the place input fields & button for
                  // showing the route
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          width: width * 0.9,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(height: 10),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: width * 0.8,
                                      child: TextField(
                                        onChanged: (value) async {
                                          if (value.isNotEmpty) {
                                            showPlacesMenu = true;
                                            GPlaces.AutocompleteResponse?
                                                result;
                                            if (_debounce?.isActive ?? false) {
                                              _debounce?.cancel();
                                            }
                                            _debounce = Timer(
                                                const Duration(
                                                    milliseconds: 200),
                                                () async {
                                              result = await googlePlace
                                                  .autocomplete
                                                  .get(value);
                                              if (result != null &&
                                                  result?.predictions != null &&
                                                  mounted) {
                                                setState(() {
                                                  predictions =
                                                      result!.predictions!;
                                                  _destinationValue = value;
                                                });
                                              }
                                            });
                                          } else {
                                            showPlacesMenu = false;
                                          }
                                        },
                                        controller:
                                            destinationAddressController,
                                        focusNode: desrinationAddressFocusNode,
                                        decoration: InputDecoration(
                                          prefixIcon:
                                              const Icon(Icons.directions_car),
                                          labelText: "Destination",
                                          filled: true,
                                          fillColor: Colors.white,
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey.shade400,
                                              width: 2,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                const BorderRadius.all(
                                              Radius.circular(10.0),
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.blue.shade300,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.all(15),
                                          hintText: 'Choose destination',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Visibility(
                                        visible: showPlacesMenu,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              color: Colors.white,
                                            ),
                                            height: height * 0.4,
                                            width: width * 0.8,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ListView.builder(
                                                  itemCount: predictions.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var pred =
                                                        predictions[index];
                                                    return ListTile(
                                                      leading: Icon(Icons
                                                          .pin_drop_outlined),
                                                      title: TextCustom(
                                                        pred.description ??
                                                            'Unnamed',
                                                        size: 16,
                                                      ),
                                                      onTap: () async {
                                                        try {
                                                          var res = await geocoder
                                                              .geocoding
                                                              .get(
                                                                  pred.description ??
                                                                      '',
                                                                  []);
                                                          var loc = res
                                                              ?.results![0]
                                                              .geometry
                                                              ?.location;
                                                          _destinationPos =
                                                              LatLng(
                                                                  loc?.lat ?? 0,
                                                                  loc?.lng ??
                                                                      0);
                                                          _destinationValue =
                                                              pred.description ??
                                                                  '';
                                                          var status =
                                                              await _setDestination();
                                                          if (!status) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'There seems to be some error!'),
                                                              ),
                                                            );
                                                          }
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          setState(() {
                                                            showPlacesMenu =
                                                                false;
                                                          });
                                                        } catch (e) {
                                                          log(e.toString());
                                                        }
                                                      },
                                                    );
                                                  }),
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Show current location button
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 10.0, bottom: 10.0),
                        child: ClipOval(
                          child: Material(
                            color: Colors.orange.shade100, // button color
                            child: InkWell(
                              splashColor: Colors.orange, // inkwell color
                              child: const SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.my_location),
                              ),
                              onTap: () {
                                mapController.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: _currentPosition,
                                      //bearing: 180,
                                      tilt: 50,
                                      zoom: 18.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void checkParkingStillFree() {
    ParkingFirestore _parkingFirestore = ParkingFirestore();
    _parkingFirestore.parkings.listen((event) {
      if (selectedParkingIndex != -1) {
        var park = event[selectedParkingIndex];
        if (park.availableSLots < 5) {
          if (!hasShownLowParkingNotif) {
            hasShownLowParkingNotif = true;
            NotificationApi.showNotification(
                id: 0,
                title: 'Low Parking!!!',
                body:
                    'There are less than 5 parking lots left. Click here if you want to change the location.');
          }
        } else {
          hasShownLowParkingNotif = false;
        }
      }
    }).onError((e) {
      log(e.toString());
    });
  }

  Future<void> initFunc() async {
    setState(() {
      isLoading = true;
    });
    await _getCurrentLocation();
    checkParkingStillFree();
    geocoder = GeoCoder.GoogleGeocoding(googleAPIKey);
    googlePlace = GPlaces.GooglePlace(googleAPIKey);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    initFunc();
    super.initState();
  }
}
