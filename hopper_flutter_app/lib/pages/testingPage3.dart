import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';
import 'package:hopper_flutter_app/pages/testingPage2.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:hopper_flutter_app/utils/data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../custom/borderBox.dart';

class testingPage3 extends StatefulWidget {
  const testingPage3({Key? key}) : super(key: key);

  @override
  State<testingPage3> createState() => _testingPage3State();
}

class _testingPage3State extends State<testingPage3> {
  final GOOGLE_API_KEY = 'AIzaSyA6wfyquzmWj59qJNGP-j4sqIqV16cuAZs';
  //For opening Menu draw
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  //Setting up google map example
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  //Setting up polyline to mark map
  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  // Setting up custom markers
  late BitmapDescriptor originIcon;
  late BitmapDescriptor destinationIcon;

  late LocationData currentLocation;
  late LocationData destinationLocation;

  late Location location;

  @override
  void initState() {
    super.initState();

    //Creating instance of Location and PolylinePoints
    location = Location();
    polylinePoints = PolylinePoints();

    setInitLocation();

    location.onLocationChanged.listen((l) {
      currentLocation = l;
      updatePinOnMap();
    });

    setOriginAndDestinationIcons();
  }

  void setOriginAndDestinationIcons() async {
    originIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1, size: Size(.0001, .0001)),
        "assets/image/image.png");
    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1, size: Size(.0001, .0001)),
        "assets/image/image.png");
  }

  void setInitLocation() async {
    currentLocation = await location.getLocation();
    destinationLocation = LocationData.fromMap(
        {"latitude": -45.031196115254865, "longitude": 168.6629237476333});
  }

  void showPinsOnMap() {
    // ERROR
    //Getting ___ has not been initialized for currentLocation and destinationLocation
    //Fixed by init the positions earlier in the program

    //Get pin position for current location
    var pinPosition = LatLng(currentLocation.latitude as double,
        currentLocation.longitude as double);

    //Get pin position for destination location
    var destPosition = LatLng(destinationLocation.latitude as double,
        destinationLocation.longitude as double);

    setState(() {
      //Create marker for Origin
      _markers.add(Marker(
          markerId: MarkerId('Origin Pin'),
          position: pinPosition,
          icon: originIcon));

      //Create marker for Destination
      _markers.add(Marker(
          markerId: MarkerId('Destination Pin'),
          position: destPosition,
          icon: destinationIcon));
    });

    //Create polyline for map
    setPolylines();
  }

  void setPolylines() async {
    //Get all LatLng values for route
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        GOOGLE_API_KEY,
        PointLatLng(currentLocation.latitude as double,
            currentLocation.longitude as double),
        PointLatLng(destinationLocation.latitude as double,
            destinationLocation.longitude as double));

    //Load into polylineCoordinates
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    //Load into the map
    setState(() {
      Polyline polyline = Polyline(
          width: 3,
          polylineId: PolylineId('Test route'),
          color: Colors.blue,
          points: polylineCoordinates);

      _polylines.add(polyline);
    });
  }

  void updatePinOnMap() async {
    CameraPosition cameraPosition = CameraPosition(
        zoom: 11,
        tilt: 20,
        target: LatLng(currentLocation.latitude as double,
            currentLocation.longitude as double));

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    setState(() {
      var pinPosition = LatLng(currentLocation.latitude as double,
          currentLocation.longitude as double);

      _markers.removeWhere((m) => m.markerId.value == 'Origin Pin');

      _markers.add(Marker(
          markerId: MarkerId('Origin Pin'),
          position: pinPosition,
          icon: originIcon));
    });
  }

  // late GoogleMapController mapController;
  // late LatLng _center = const LatLng(45.521563, -122.677433);

  // Location location = Location();

  // void _onMapCreated(GoogleMapController controller) {
  //   mapController = controller;
  //   location.onLocationChanged.listen((l) {
  //     controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //         target: LatLng(l.latitude as double, l.longitude as double),
  //         zoom: 11)));
  //   });
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   checkLocationServicePermission();
  // }

  // Future<void> checkLocationServicePermission() async {
  //   var _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled) {
  //       print("Service granted");
  //     }
  //   }

  //   var _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted == PermissionStatus.granted) {
  //       print("Permission granted");
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    const double padding = 25;

    final origin = TextEditingController();
    final destination = TextEditingController();

    CameraPosition initCameraPosition = const CameraPosition(
        target: LatLng(-44.94982353905404, 168.84470407617113),
        zoom: 20,
        tilt: 45);

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Hopper",
            style: themeData.textTheme.headline1,
          ),
          backgroundColor: Colors.white,
          foregroundColor: PRIMARY_COLOR,
        ),
        drawer: menuDraw(),
        key: _key,
        body: SafeArea(
            bottom: false,
            child: SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    GoogleMap(
                      initialCameraPosition: initCameraPosition,
                      // initialCameraPosition: CameraPosition(
                      //     target: LatLng(currentLocation.latitude as double,
                      //         currentLocation.longitude as double),
                      //     zoom: 20.0,
                      //     tilt: 45),
                      mapType: MapType.normal,
                      polylines: _polylines,
                      markers: _markers,
                      myLocationEnabled: true,
                      tiltGesturesEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);

                        //Map has been created and is now showing pins on map
                        showPinsOnMap();
                      },
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Column(children: <Widget>[
                        // Container(
                        //     decoration: const BoxDecoration(
                        //         borderRadius: BorderRadius.only(
                        //             bottomLeft: Radius.circular(8.0),
                        //             bottomRight: Radius.circular(8.0)),
                        //         color: COLOR_WHITE),
                        //     child: Padding(
                        //         padding: const EdgeInsets.all(padding),
                        //         child: Row(
                        //           crossAxisAlignment: CrossAxisAlignment.center,
                        //           mainAxisAlignment:
                        //               MainAxisAlignment.spaceBetween,
                        //           children: <Widget>[
                        //             BorderBox(
                        //               height: 50,
                        //               width: 50,
                        //               padding: const EdgeInsets.all(8.0),
                        //               callback: menu,
                        //               child: const Icon(Icons.menu,
                        //                   color: PRIMARY_COLOR),
                        //             ),
                        //             Text("Hopper",
                        //                 style: themeData.textTheme.headline1),
                        //             const SizedBox(height: 50, width: 50)
                        //           ],
                        //         ))),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(
                                padding, 10, padding, 0),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: COLOR_WHITE),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: padding, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    TextField(
                                      controller: origin,
                                      decoration: const InputDecoration(
                                          labelText: "Origin"),
                                    ),
                                    TextField(
                                      controller: destination,
                                      decoration: InputDecoration(
                                          labelText: "Destination",
                                          suffixIcon: IconButton(
                                              onPressed: search,
                                              icon: const Icon(Icons.send))),
                                    )
                                  ],
                                ))),
                      ]),
                    ),
                    Positioned(
                        bottom: padding,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: padding),
                          child: RouteCard(itemData: RE_DATA[0]),
                        )),
                  ],
                ))));
  }

  void menu() {
    _key.currentState!.openDrawer();
  }

  void search() {
    print("SHIT");
  }
}
