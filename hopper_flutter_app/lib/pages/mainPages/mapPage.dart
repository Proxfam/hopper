import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:location/location.dart';

import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../custom/database.dart';
import 'mapWidgets.dart';

class mapPage extends StatefulWidget {
  const mapPage({Key? key}) : super(key: key);

  @override
  State<mapPage> createState() => _mapPageState();
}

class _mapPageState extends State<mapPage> {
  // TextEditingController originController =
  //     TextEditingController(text: "12 Alexander Place, Arrowtown");
  // TextEditingController destinationController =
  //     TextEditingController(text: "47 red oaks drive, Frankton");

  // TextEditingController originController =
  //     TextEditingController(text: "47 Red oaks drive, Frankton");
  // TextEditingController destinationController =
  //     TextEditingController(text: "35 brecon street, Queenstown");

  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  late DateTime departureTime;
  late DateTime arrivalTime;

  late GoogleMapController mapController;
  late Future<List<dynamic>> rideResults;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<dynamic> rideList = [];

  bool searchingForRides = false;
  bool expanded = false;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    rideResults = setRideResults();
  }

  Future<List<dynamic>> setRideResults() async {
    return [true];
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    originController.dispose();
    destinationController.dispose();
  }

  Future<List> updateRideResults() async {
    setState(() {
      polylines = {};
      markers = {};
    });
    // try {
    //   print(departureTime);
    // } catch (e) {
    //   print(e);
    // }
    // setState(() {
    //   searchingForRides = false;
    // });
    // return [];
    if (originController.text == "" || destinationController.text == "") {
      setState(() {
        searchingForRides = false;
      });
      return [];
    }

    try {
      print(departureTime.toString());
    } catch (e) {
      departureTime = DateTime.now();
    }

    var response = await http
        .post(
          Uri.parse(
              'https://us-central1-hopper-2.cloudfunctions.net/searchRides'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $GCFauth'
          },
          body: jsonEncode(<String, dynamic>{
            'origin': originController.text,
            'destination': destinationController.text,
            'originRadius': 3,
            'destinationRadius': 3,
            'departureTime': departureTime.toString(),
          }),
        )
        .catchError((e) => print(e));

    try {
      setState(() {
        searchingForRides = false;
      });
      return jsonDecode(response.body);
    } catch (e) {
      return [jsonDecode(response.body)['error']];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Location location = Location();

    scrollController.addListener(
      () async {
        //print(scrollController.position.pixels);
        if (scrollController.position.pixels %
                MediaQuery.of(context).size.width ==
            0) {
          var currentRide = (scrollController.position.pixels /
                  MediaQuery.of(context).size.width)
              .round();

          //print((await rideResults)[currentRide]['ride']['coords']);

          List<LatLng> coords = [];

          //Declares coords and stuff
          for (var coord in (await rideResults)[currentRide]['sortedCoords']) {
            coords.add(LatLng(double.parse(coord['_latitude'].toString()),
                double.parse(coord['_longitude'].toString())));
          }

          //displays the shit
          setState(() {
            //find LatLng bounds for polyline display
            double minLat = coords[0].latitude;
            double minLong = coords[0].longitude;
            double maxLat = coords[0].latitude;
            double maxLong = coords[0].longitude;
            for (var coord in coords) {
              if (coord.latitude < minLat) minLat = coord.latitude;
              if (coord.latitude > maxLat) maxLat = coord.latitude;
              if (coord.longitude < minLong) {
                minLong = coord.longitude;
              }
              if (coord.longitude > maxLong) {
                maxLong = coord.longitude;
              }
            }

            //moves camera
            mapController.animateCamera(CameraUpdate.newLatLngBounds(
                LatLngBounds(
                    southwest: LatLng(minLat, minLong),
                    northeast: LatLng(maxLat, maxLong)),
                50));

            //clears markers and polylines
            markers.clear();
            polylines.clear();

            // markers = {
            //   Marker(
            //       infoWindow: const InfoWindow(
            //           title: "Tester", snippet: "This is a cute test thing"),
            //       markerId: const MarkerId("lolz"),
            //       position: LatLng(coords[0].latitude, coords[0].longitude))
            // };

            polylines = {
              Polyline(
                endCap: Cap.roundCap,
                jointType: JointType.round,
                patterns: [PatternItem.dash(10), PatternItem.gap(10)],
                width: 3,
                polylineId: const PolylineId("firster"),
                points: coords,
                color: Colors.blue,
              )
            };
          });
        }
      },
    );

    return Stack(children: [
      GoogleMap(
        rotateGesturesEnabled: false,
        markers: markers,
        polylines: polylines,
        padding: const EdgeInsets.only(bottom: 0, top: 100),
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
          if (NIGHTMODE) {
            rootBundle.loadString('assets/nightMapStyle.json').then(
              (String mapStyle) {
                mapController.setMapStyle(mapStyle);
              },
            );
          }
        },
        initialCameraPosition: const CameraPosition(
          target: LatLng(-45.00202331256251, 168.75192027169524),
          zoom: 11.0,
        ),
      ),
      SafeArea(
          child: SizedBox(
              height: 125,
              child: FutureBuilder(
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                      }
                      if (snapshot.hasData) {
                        var data = snapshot.data as List<dynamic>;
                        if (data.isNotEmpty) {
                          if (data[0] == true) {
                            return const SizedBox.shrink();
                          }
                          rideList = data.toList();

                          if (rideList[0].runtimeType == String) {
                            // setState(() {
                            //   searchingForRides = true;
                            //   rideResults = updateRideResults();
                            // });
                            // WidgetsBinding.instance.addPostFrameCallback(
                            //   (timeStamp) {
                            //     setState(() {
                            //       searchingForRides = true;
                            //       rideResults = updateRideResults();
                            //     });
                            //   },
                            // );

                            return ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Padding(
                                    //padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 20),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                60,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 20),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Server error",
                                              style:
                                                  themeData.textTheme.headline6,
                                            ),
                                            Text(
                                              rideList[0].toString(),
                                              style:
                                                  themeData.textTheme.bodyText1,
                                            ),
                                          ],
                                        )))
                              ],
                            );
                          }

                          return ListView(
                            controller: scrollController,
                            physics: const PageScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children: data
                                .map(((e) => rideResult(
                                    data: e,
                                    scrollController: scrollController)))
                                .toList(),
                          );
                        } else {
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                  //padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('No rides found',
                                                style: themeData
                                                    .textTheme.headline6)
                                          ])))
                            ],
                          );
                        }
                      }
                    }

                    return ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                            //padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Container(
                                width: MediaQuery.of(context).size.width - 40,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 20),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Searching for rides...",
                                      style: themeData.textTheme.headline6,
                                    ),
                                    Text(
                                      "Please wait while we search for rides...",
                                      style: themeData.textTheme.bodyText1,
                                    ),
                                  ],
                                )))
                      ],
                    );
                  }),
                  future: rideResults))),
      // Positioned(
      //   bottom: 210,
      //   left: 0,
      //   child: OutlinedButton(
      //       child: const Text("Zoom out"),
      //       onPressed: () {
      //         mapController.moveCamera(CameraUpdate.zoomOut());
      //       }),
      // ),
      // Positioned(
      //   bottom: 175,
      //   left: 0,
      //   child: OutlinedButton(
      //       child: const Text("Zoom in"),
      //       onPressed: () {
      //         mapController.moveCamera(CameraUpdate.zoomIn());
      //       }),
      // ),
      rideSearcher(
          originController: originController,
          destinationController: destinationController,
          isLoading: searchingForRides,
          expanded: expanded,
          callback: (DateTime givenTime) {
            departureTime = givenTime;
            setState(() {
              searchingForRides = true;
              expanded = false;
              rideResults = updateRideResults();
            });
          }),
      AnimatedPositioned(
          duration: Duration(milliseconds: 750),
          curve: Curves.fastLinearToSlowEaseIn,
          bottom: 30,
          right: expanded ? -70 : 20,
          child: Container(
              height: 70,
              width: 70,
              child: FloatingActionButton(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      expanded = true;
                    });
                  },
                  child: Padding(
                      padding: EdgeInsets.all(17),
                      child: searchingForRides
                          ? CircularProgressIndicator(
                              color: Colors.grey.shade700)
                          : Icon(
                              Icons.search,
                              size: 40,
                              color: Colors.grey.shade700,
                            )))))
    ]);
  }
}
