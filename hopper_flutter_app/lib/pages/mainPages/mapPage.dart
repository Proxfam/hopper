import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  TextEditingController originController =
      TextEditingController(text: "12 Alexander Place, Arrowtown");
  //TextEditingController(text: "Bali");
  TextEditingController destinationController =
      TextEditingController(text: "47 Red oaks drive, Frankton");

  late GoogleMapController mapController;
  late Future<List<dynamic>> rideResults;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  List<dynamic> rideList = [];

  @override
  void initState() {
    super.initState();
    rideResults = updateRideResults();
  }

  @override
  void dispose() {
    super.dispose();
    mapController.dispose();
    originController.dispose();
    destinationController.dispose();
  }

  Future<List> updateRideResults() async {
    if (originController.text == "" || destinationController.text == "") {
      return [];
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
            'originRadius': 2,
            'destinationRadius': 2
          }),
        )
        .catchError((e) => print(e));

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    Location location = Location();
    ScrollController scrollController = ScrollController();

    scrollController.addListener(
      () async {
        //print(scrollController.position.pixels);
        if (scrollController.position.pixels %
                MediaQuery.of(context).size.width ==
            0) {
          var currentRide = (scrollController.position.pixels /
                  MediaQuery.of(context).size.width)
              .round();

          //Declares coords and stuff
          List<LatLng> coords = [];
          List<dynamic> sortedCoords =
              (await rideResults)[currentRide]['rideCoords'];

          //sorts coords by id so it's in order when displayed
          sortedCoords.sort((a, b) {
            var result = double.parse(a['_ref']['_path']['segments'][3]) >
                double.parse(b['_ref']['_path']['segments'][3]);
            return result ? 1 : -1;
          });

          //loads it into coord in LatLng format
          for (var coord in sortedCoords) {
            if (coord['_fieldsProto']['lat']['valueType'] == 'doubleValue' &&
                coord['_fieldsProto']['lng']['valueType'] == 'doubleValue') {
              coords.add(LatLng(coord['_fieldsProto']['lat']['doubleValue'],
                  coord['_fieldsProto']['lng']['doubleValue']));
            } else if (coord['_fieldsProto']['lat']['valueType'] ==
                    'doubleValue' &&
                coord['_fieldsProto']['lng']['valueType'] == 'integerValue') {
              coords.add(LatLng(coord['_fieldsProto']['lat']['doubleValue'],
                  double.parse(coord['_fieldsProto']['lng']['integerValue'])));
            } else if (coord['_fieldsProto']['lat']['valueType'] ==
                    'integerValue' &&
                coord['_fieldsProto']['lng']['valueType'] == 'doubleValue') {
              coords.add(LatLng(
                  double.parse(coord['_fieldsProto']['lat']['integerValue']),
                  coord['_fieldsProto']['lng']['doubleValue']));
            } else if (coord['_fieldsProto']['lat']['valueType'] ==
                    'integerValue' &&
                coord['_fieldsProto']['lng']['valueType'] == 'integerValue') {
              coords.add(LatLng(
                  double.parse(coord['_fieldsProto']['lat']['integerValue']),
                  double.parse(coord['_fieldsProto']['lng']['integerValue'])));
            }
          }

          //displays the shit
          setState(() {
            //find LatLng bounds for polyline display
            double minLat = coords[0].latitude;
            double minLong = coords[0].longitude;
            double maxLat = coords[0].latitude;
            double maxLong = coords[0].longitude;
            for (var point in coords) {
              if (point.latitude < minLat) minLat = point.latitude;
              if (point.latitude > maxLat) maxLat = point.latitude;
              if (point.longitude < minLong) {
                minLong = point.longitude;
              }
              if (point.longitude > maxLong) {
                maxLong = point.longitude;
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
        padding: const EdgeInsets.only(bottom: 145, top: 100),
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
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
                          rideList = data.toList();

                          return ListView(
                            controller: scrollController,
                            physics: const PageScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            children:
                                data.map(((e) => rideResult(data: e))).toList(),
                          );
                        } else {
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Padding(
                                  //padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 20),
                                  child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 20),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Text('No rides found')
                                          ])))
                            ],
                          );
                        }
                      }
                    }

                    return const SizedBox.shrink();
                  }),
                  future: rideResults))),
      Positioned(
        bottom: 210,
        left: 0,
        child: OutlinedButton(
            child: const Text("Zoom out"),
            onPressed: () {
              mapController.moveCamera(CameraUpdate.zoomOut());
            }),
      ),
      Positioned(
        bottom: 175,
        left: 0,
        child: OutlinedButton(
            child: const Text("Zoom in"),
            onPressed: () {
              mapController.moveCamera(CameraUpdate.zoomIn());
            }),
      ),
      Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: rideSearcher(
              originController: originController,
              destinationController: destinationController,
              callback: () {
                setState(() {
                  rideResults = updateRideResults();
                });
              }))
    ]);
  }
}
