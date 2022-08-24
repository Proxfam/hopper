import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:hopper_flutter_app/main.dart';
import 'package:hopper_flutter_app/pages/accountPages/accountPage.dart';
import 'package:hopper_flutter_app/pages/accountPages/listitem.dart';

import '../../utils/contants.dart';

class rideDetails extends StatefulWidget {
  const rideDetails({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  State<rideDetails> createState() => _rideDetailsState();
}

class _rideDetailsState extends State<rideDetails> {
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  bool paymentInProgress = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    List<LatLng> coords = [];

    Color colorAccent = Colors.green.shade400;

    List driverReviews = [
      {
        'name': 'Cam Mackenzie',
        'comment':
            'Kane was very friendly, although the car was a little messy. Overall he was very accommodating and helpful. I would definitely recommend him to anyone looking for a driver.'
      },
      {'name': 'Lily Kay', 'comment': 'nah pre shit aye'}
    ];

    for (var coord in widget.data['sortedCoords']) {
      coords.add(LatLng(double.parse(coord['_latitude'].toString()),
          double.parse(coord['_longitude'].toString())));
    }

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

    void onMapCreated(GoogleMapController mapController) {
      if (NIGHTMODE) {
        rootBundle.loadString('assets/nightMapStyle.json').then(
          (String mapStyle) {
            mapController.setMapStyle(mapStyle);
          },
        );
      } else {
        rootBundle.loadString('assets/dayMapStyle.json').then(
          (String mapStyle) {
            mapController.setMapStyle(mapStyle);
          },
        );
      }

      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLong),
            northeast: LatLng(maxLat, maxLong),
          ),
          35,
        ),
      );

      setState(() {
        polylines = {
          Polyline(
            width: 3,
            polylineId: const PolylineId("firster"),
            points: coords,
            color: Colors.blue,
          )
        };
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey.shade400,
        shadowColor: Colors.transparent,
      ),
      body: ListView(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Route',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: GoogleMap(
                  onMapCreated: onMapCreated,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-45.00202331256251, 168.75192027169524),
                    zoom: 11.0,
                  ),
                  polylines: polylines,
                  markers: markers,
                ),
              ),
            ),
          ]),
        ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Schedule',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
              Container(
                  height: 275,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade100),
                  child: Row(children: [
                    Column(children: [
                      Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(90)),
                            border: Border.all(
                              width: 2,
                              color: colorAccent,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Icon(Icons.home, color: colorAccent)),
                      Expanded(
                          child: Container(
                        width: 2,
                        decoration: BoxDecoration(color: colorAccent),
                      )),
                      Container(
                          height: 125,
                          width: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(90)),
                            border: Border.all(
                              width: 2,
                              color: colorAccent,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.directions_car_filled,
                                    color: colorAccent),
                                Text(
                                    "${DateTime.parse(widget.data['times']['hopOff'].toString()).difference(DateTime.parse(widget.data['times']['hopOn'].toString())).inMinutes.toString()} min",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: colorAccent))
                              ])),
                      Expanded(
                          child: Container(
                        width: 2,
                        decoration: BoxDecoration(color: colorAccent),
                      )),
                      Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(90)),
                            border: Border.all(
                              width: 2,
                              color: colorAccent,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: const Icon(
                            Icons.pin_drop,
                            color: Colors.white,
                          )),
                    ]),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Origin",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text(widget.data['locations']['origin'])
                                    ]),
                                SizedBox(
                                    width: 140,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Leave by"),
                                          Text(
                                              "${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['leaveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['leaveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['leaveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? "PM" : "AM"}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorAccent))
                                        ]))
                              ]),
                          SizedBox(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  "${widget.data['driver']['displayInfo']['firstName']}'s Ride",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.data['locations']['pickup']
                                          ['address']),
                                      SizedBox(
                                          width: 140,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Pick up"),
                                                Text(
                                                    "${DateTime.parse(widget.data['times']['hopOn'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['hopOn'].toString()).hour - 12 : DateTime.parse(widget.data['times']['hopOn'].toString()).hour}:${DateTime.parse(widget.data['times']['hopOn'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['hopOn'].toString()).minute}" : DateTime.parse(widget.data['times']['hopOn'].toString()).minute} ${DateTime.parse(widget.data['times']['hopOn'].toString()).hour > 12 ? "PM" : "AM"}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: colorAccent))
                                              ]))
                                    ]),
                                const Divider(),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(widget.data['locations']['dropoff']
                                          ['address']),
                                      SizedBox(
                                          width: 140,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text("Drop off"),
                                                Text(
                                                    "${DateTime.parse(widget.data['times']['hopOff'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['hopOff'].toString()).hour - 12 : DateTime.parse(widget.data['times']['hopOff'].toString()).hour}:${DateTime.parse(widget.data['times']['hopOff'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['hopOff'].toString()).minute}" : DateTime.parse(widget.data['times']['hopOff'].toString()).minute} ${DateTime.parse(widget.data['times']['hopOff'].toString()).hour > 12 ? "PM" : "AM"}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: colorAccent))
                                              ]))
                                    ]),
                                const SizedBox(height: 10)
                              ])),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Destination",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text(widget.data['locations']
                                          ['destination'])
                                    ]),
                                SizedBox(
                                    width: 140,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Arrive by"),
                                          Text(
                                              "${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['arriveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['arriveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['arriveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? "PM" : "AM"}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorAccent))
                                        ]))
                              ]),
                        ]))
                  ])),
            ])),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Driver',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(children: [
                Row(children: [
                  const CircleAvatar(),
                  const SizedBox(width: 10),
                  Text(
                    "${widget.data['driver']['displayInfo']['firstName']} ${widget.data['driver']['displayInfo']['lastName']}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  const SizedBox(width: 10)
                ]),
                const Divider(),
                Row(children: [
                  const Icon(Icons.phone),
                  const SizedBox(width: 10),
                  Text(
                    widget.data['driver']['displayInfo']['phoneNumber'],
                    style: const TextStyle(fontSize: 18),
                  )
                ]),
                const SizedBox(height: 10),
                SizedBox(
                    height: 175,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const PageScrollPhysics(),
                          itemCount: driverReviews.length,
                          itemBuilder: (context, index) {
                            return Container(
                                width: MediaQuery.of(context).size.width - 50,
                                padding: const EdgeInsets.all(10),
                                decoration:
                                    BoxDecoration(color: Colors.grey.shade200),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        const CircleAvatar(),
                                        const SizedBox(width: 10),
                                        Text(driverReviews[index]['name'])
                                      ]),
                                      const Divider(),
                                      Text(driverReviews[index]['comment']),
                                    ]));
                          },
                        )))
              ]),
            )
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                'Passengers',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(90)),
                  child: const Text(
                    "3/4 Seats",
                    style: TextStyle(color: Colors.white, height: 1.2),
                    textAlign: TextAlign.center,
                  ))
            ]),
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: const [
                        CircleAvatar(),
                        SizedBox(width: 10),
                        Text(
                          "Sophie Wood",
                          style: TextStyle(fontSize: 15, height: 1.25),
                        ),
                        Spacer(),
                        Icon(Icons.more_vert_rounded)
                      ]),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      Row(children: const [
                        CircleAvatar(),
                        SizedBox(width: 10),
                        Text(
                          "Breye Becker",
                          style: TextStyle(fontSize: 15, height: 1.25),
                        ),
                        Spacer(),
                        Icon(Icons.more_vert_rounded)
                      ]),
                      const SizedBox(height: 5),
                      const Divider(),
                      const SizedBox(height: 5),
                      Row(children: const [
                        CircleAvatar(),
                        SizedBox(width: 10),
                        Text(
                          "Will kidd",
                          style: TextStyle(fontSize: 15, height: 1.25),
                        ),
                        Spacer(),
                        Icon(Icons.more_vert_rounded)
                      ])
                    ]))
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(
              'Payment',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Driver fee"),
                        Text(
                          "\$${double.parse(widget.data['payment']['driverCost'].toString()).toStringAsFixed(2)}",
                          style: TextStyle(
                              color: colorAccent, fontWeight: FontWeight.bold),
                        )
                      ]),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Hopper fee"),
                        Text(
                            "\$${double.parse(widget.data['payment']['serviceFee'].toString()).toStringAsFixed(2)}",
                            style: TextStyle(
                                color: colorAccent,
                                fontWeight: FontWeight.bold))
                      ]),
                  const Divider(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: const TextStyle(fontSize: 24),
                        ),
                        Text(
                            "\$${double.parse((widget.data['payment']['driverCost'] + widget.data['payment']['serviceFee']).toString()).toStringAsFixed(2)}",
                            style: TextStyle(
                                color: colorAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 24))
                      ])
                ])),
            OutlinedButton(
                onPressed: () {
                  if (!paymentInProgress) {
                    setState(() {
                      paymentInProgress = true;
                    });
                    initPaymentSheet(context,
                        amount: double.parse((widget.data['payment']
                                        ['driverCost'] +
                                    widget.data['payment']['serviceFee'])
                                .toString()) *
                            100, success: (response) async {
                      await FirebaseFirestore.instance
                          .collection('rides')
                          .doc(widget.data['rideID'])
                          .update({
                        'passengers': [
                          {
                            'uid': FirebaseAuth.instance.currentUser?.uid,
                            'locations': widget.data['locations'],
                            'payment': {
                              'serviceFee': widget.data['payment']
                                  ['serviceFee'],
                              'driverFee': widget.data['payment']['driverCost'],
                              'paymentID': jsonDecode(response)['paymentIntent']
                            },
                            'times': widget.data['times']
                          }
                        ]
                      });
                      setState(() {
                        paymentInProgress = false;
                      });
                      Navigator.pop(context);
                    }, error: (e) {
                      setState(() {
                        paymentInProgress = false;
                      });
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                    side: BorderSide.none, backgroundColor: Colors.green),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: paymentInProgress
                        ? [
                            const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ))
                          ]
                        : const [
                            Text("Pay", style: TextStyle(color: Colors.white)),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward,
                                color: Colors.white, size: 20)
                          ]))
          ]),
        ),
      ]),
    );

    // return Scaffold(
    //     appBar: AppBar(
    //       backgroundColor: Colors.transparent,
    //       foregroundColor: Colors.grey.shade400,
    //       shadowColor: Colors.transparent,
    //     ),
    //     extendBodyBehindAppBar: true,
    //     body: Column(
    //         //mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //         //crossAxisAlignment: CrossAxisAlignment.stretch,
    //         children: [
    //           SizedBox(
    //               height: 300,
    //               child: GoogleMap(
    //                 polylines: polylines,
    //                 markers: markers,
    //                 onMapCreated: onMapCreated,
    //                 rotateGesturesEnabled: false,
    //                 scrollGesturesEnabled: false,
    //                 zoomControlsEnabled: false,
    //                 zoomGesturesEnabled: false,
    //                 myLocationEnabled: false,
    //                 myLocationButtonEnabled: false,
    // initialCameraPosition: const CameraPosition(
    //   target: LatLng(-45.00202331256251, 168.75192027169524),
    //   zoom: 11.0,
    // ),
    //               )),
    //           // Expanded(
    //           //     child: ListView.builder(
    //           //         padding: EdgeInsets.zero,
    //           //         itemBuilder: ((context, index) {
    //           //           //make the times a list so I can itterate through them without having to ref each time individually
    //           //           //add enough details into each card so that the user can see the each step of the ride

    //           //           var title;
    //           //           var time;
    //           //           var icon;
    //           //           var radius = BorderRadius.circular(4.0);
    //           //           var padding = const EdgeInsets.symmetric(
    //           //               horizontal: 20, vertical: 10);
    //           //           switch (index) {
    //           //             case 0:
    //           //               time =
    //           //                   "${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['leaveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['leaveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['leaveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? "PM" : "AM"}";
    //           //               title = "Leave By";
    //           //               icon = const Icon(Icons.directions_walk);
    //           //               break;
    //           //             case 1:
    //           //               time =
    //           //                   "${DateTime.parse(widget.data['times']['hopOn'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['hopOn'].toString()).hour - 12 : DateTime.parse(widget.data['times']['hopOn'].toString()).hour}:${DateTime.parse(widget.data['times']['hopOn'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['hopOn'].toString()).minute}" : DateTime.parse(widget.data['times']['hopOn'].toString()).minute} ${DateTime.parse(widget.data['times']['hopOn'].toString()).hour > 12 ? "PM" : "AM"}";
    //           //               title = "Pick Up";
    //           //               icon = const Icon(Icons.directions_car);
    //           //               radius = const BorderRadius.only(
    //           //                   topLeft: Radius.circular(4.0),
    //           //                   topRight: Radius.circular(4.0));
    //           //               padding = const EdgeInsets.only(
    //           //                   top: 10, left: 20, right: 20);
    //           //               break;
    //           //             case 2:
    //           //               time =
    //           //                   "${DateTime.parse(widget.data['times']['hopOff'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['hopOff'].toString()).hour - 12 : DateTime.parse(widget.data['times']['hopOff'].toString()).hour}:${DateTime.parse(widget.data['times']['hopOff'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['hopOff'].toString()).minute}" : DateTime.parse(widget.data['times']['hopOff'].toString()).minute} ${DateTime.parse(widget.data['times']['hopOff'].toString()).hour > 12 ? "PM" : "AM"}";
    //           //               title = "Drop off";
    //           //               //icon = const Icon(Icons.directions_car);
    //           //               radius = const BorderRadius.only(
    //           //                   bottomLeft: Radius.circular(4.0),
    //           //                   bottomRight: Radius.circular(4.0));
    //           //               padding = const EdgeInsets.only(
    //           //                   bottom: 10, left: 20, right: 20);
    //           //               break;
    //           //             case 3:
    //           //               time =
    //           //                   "${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['arriveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['arriveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['arriveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? "PM" : "AM"}";
    //           //               title = "Arrive By";
    //           //               icon = const Icon(Icons.directions_walk);
    //           //           }
    //           //           icon = null;
    //           //           return Padding(
    //           //               padding: padding,
    //           //               child: Container(
    //           //                   // padding: const EdgeInsets.symmetric(
    //           //                   //     horizontal: 2.5, vertical: 1.75),
    //           //                   decoration: BoxDecoration(
    //           //                       color: Colors.grey.shade200,
    //           //                       borderRadius: radius),
    //           //                   child: ListTile(
    //           //                     dense: true,
    //           //                     title: Text(title),
    //           //                     subtitle: Text(time),
    //           //                     trailing: icon,
    //           //                   )));
    //           //         }),
    //           //         itemCount: widget.data['times'].length)),
    //           Expanded(
    //               child: Column(
    //                   crossAxisAlignment: CrossAxisAlignment.stretch,
    //                   children: [
    //                 Padding(
    //                     padding: const EdgeInsets.symmetric(
    //                         horizontal: 20, vertical: 10),
    //                     child: Container(
    //                         decoration: BoxDecoration(
    //                             color: Colors.grey.shade200,
    //                             borderRadius: BorderRadius.circular(4.0)),
    //                         child: Row(children: [
    //                           Padding(
    //                               padding: EdgeInsets.all(20),
    //                               child:
    //                                   Icon(Icons.access_time_filled_rounded)),
    //                           Text(
    //                               "Leave at ${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['leaveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['leaveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['leaveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? "PM" : "AM"}")
    //                         ]))),
    //                 Padding(
    //                     padding: const EdgeInsets.symmetric(
    //                         horizontal: 20, vertical: 10),
    //                     child: Container(
    //                         padding: EdgeInsets.all(20),
    //                         decoration: BoxDecoration(
    //                             color: Colors.grey.shade200,
    //                             borderRadius: BorderRadius.circular(4.0)),
    //                         child: Row(children: [
    //                           const Padding(
    //                               padding: EdgeInsets.only(right: 20),
    //                               child: Icon(Icons.directions_car)),
    //                           Flexible(
    //                               child: Column(
    //                                   crossAxisAlignment:
    //                                       CrossAxisAlignment.stretch,
    //                                   children: [
    //                                 const Text("Kane Viggers",
    //                                     style: TextStyle(fontSize: 24)),
    //                                 Row(
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.spaceBetween,
    //                                     children: [
    //                                       Row(children: const [
    //                                         Padding(
    //                                             padding: EdgeInsets.all(5),
    //                                             child:
    //                                                 Icon(Icons.arrow_forward)),
    //                                         Text("8 Centerinal Drive")
    //                                       ]),
    //                                       Text(
    //                                           "${DateTime.parse(widget.data['times']['hopOn'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['hopOn'].toString()).hour - 12 : DateTime.parse(widget.data['times']['hopOn'].toString()).hour}:${DateTime.parse(widget.data['times']['hopOn'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['hopOn'].toString()).minute}" : DateTime.parse(widget.data['times']['hopOn'].toString()).minute} ${DateTime.parse(widget.data['times']['hopOn'].toString()).hour > 12 ? "PM" : "AM"}")
    //                                     ]),
    //                                 Row(
    //                                     mainAxisAlignment:
    //                                         MainAxisAlignment.spaceBetween,
    //                                     children: [
    //                                       Row(children: const [
    //                                         Padding(
    //                                             padding: EdgeInsets.all(5),
    //                                             child: Icon(
    //                                                 Icons.arrow_downward,
    //                                                 color: Colors.transparent)),
    //                                         Text("Event center")
    //                                       ]),
    //                                       Text(
    //                                           "${DateTime.parse(widget.data['times']['hopOff'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['hopOff'].toString()).hour - 12 : DateTime.parse(widget.data['times']['hopOff'].toString()).hour}:${DateTime.parse(widget.data['times']['hopOff'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['hopOff'].toString()).minute}" : DateTime.parse(widget.data['times']['hopOff'].toString()).minute} ${DateTime.parse(widget.data['times']['hopOff'].toString()).hour > 12 ? "PM" : "AM"}")
    //                                     ])
    //                               ]))
    //                         ]))),
    //                 Padding(
    //                     padding: const EdgeInsets.symmetric(
    //                         horizontal: 20, vertical: 10),
    //                     child: Container(
    //                         decoration: BoxDecoration(
    //                             color: Colors.grey.shade200,
    //                             borderRadius: BorderRadius.circular(4.0)),
    //                         child: Row(children: [
    //                           Padding(
    //                               padding: EdgeInsets.all(20),
    //                               child: Icon(Icons.location_pin)),
    //                           Text(
    //                               "Arrive by ${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['arriveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['arriveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['arriveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? "PM" : "AM"}")
    //                         ]))),
    //               ])),
    //           SafeArea(
    //               top: false,
    //               child: Padding(
    //                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    //                   child: Container(
    //                       decoration: BoxDecoration(
    //                           color: Colors.grey.shade200,
    //                           borderRadius: BorderRadius.circular(5.0)),
    //                       child: Padding(
    //                           padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
    //                           child: Row(
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               children: [
    //                                 Flexible(
    //                                     child: Padding(
    //                                         padding: const EdgeInsets.only(
    //                                             right: 10),
    //                                         child: Column(children: [
    //                                           Row(
    //                                               mainAxisAlignment:
    //                                                   MainAxisAlignment.center,
    //                                               children: const [
    //                                                 CircleAvatar(),
    //                                                 SizedBox(width: 10),
    //                                                 Text("Kane Viggers")
    //                                               ]),
    //                                           const Divider(),
    //                                           Padding(
    //                                               padding: const EdgeInsets
    //                                                       .symmetric(
    //                                                   horizontal: 10),
    //                                               child: Column(
    //                                                   crossAxisAlignment:
    //                                                       CrossAxisAlignment
    //                                                           .start,
    //                                                   children: [
    //                                                     Row(children: [
    //                                                       Column(
    //                                                           crossAxisAlignment:
    //                                                               CrossAxisAlignment
    //                                                                   .start,
    //                                                           children: [
    //                                                             const Text(
    //                                                                 "Leave by"),
    //                                                             Text(
    //                                                                 "${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['leaveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['leaveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['leaveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['leaveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['leaveBy'].toString()).hour > 12 ? "PM" : "AM"}",
    //                                                                 style: const TextStyle(
    //                                                                     fontWeight:
    //                                                                         FontWeight.bold)),
    //                                                           ]),
    //                                                       const SizedBox(
    //                                                           width: 10),
    //                                                       Column(
    //                                                           crossAxisAlignment:
    //                                                               CrossAxisAlignment
    //                                                                   .start,
    //                                                           children: [
    //                                                             const Text(
    //                                                                 "Arrive by"),
    //                                                             Text(
    //                                                                 "${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['times']['arriveBy'].toString()).hour - 12 : DateTime.parse(widget.data['times']['arriveBy'].toString()).hour}:${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['times']['arriveBy'].toString()).minute}" : DateTime.parse(widget.data['times']['arriveBy'].toString()).minute} ${DateTime.parse(widget.data['times']['arriveBy'].toString()).hour > 12 ? "PM" : "AM"}",
    //                                                                 style: const TextStyle(
    //                                                                     fontWeight:
    //                                                                         FontWeight.bold))
    //                                                           ]),
    //                                                     ]),
    //                                                     const Text("Car"),
    //                                                     Text(
    //                                                         widget.data['driver']
    //                                                                 [
    //                                                                 'driverInfo']
    //                                                             ['vehicle'],
    //                                                         style: const TextStyle(
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .bold)),
    //                                                     Text(
    //                                                         widget.data['driver']
    //                                                                 [
    //                                                                 'driverInfo']
    //                                                             [
    //                                                             'vehiclePlate'],
    //                                                         style: const TextStyle(
    //                                                             fontWeight:
    //                                                                 FontWeight
    //                                                                     .bold))
    //                                                   ]))
    //                                         ]))),
    //                                 Flexible(
    //                                     child: Column(
    //                                         crossAxisAlignment:
    //                                             CrossAxisAlignment.stretch,
    //                                         children: [
    //                                       Container(
    //                                           decoration: BoxDecoration(
    //                                               color: Colors.white,
    //                                               borderRadius:
    //                                                   BorderRadius.circular(
    //                                                       5.0)),
    //                                           child: Padding(
    //                                               padding: EdgeInsets.all(10),
    //                                               child: Column(
    //                                                   crossAxisAlignment:
    //                                                       CrossAxisAlignment
    //                                                           .start,
    //                                                   children: [
    //                                                     const Text("Payment"),
    //                                                     const Divider(),
    //                                                     Row(
    //                                                         mainAxisAlignment:
    //                                                             MainAxisAlignment
    //                                                                 .spaceBetween,
    //                                                         children: [
    //                                                           const Text(
    //                                                               "Driver fee:"),
    //                                                           Text(
    //                                                               "\$${double.parse(widget.data['payment']['driverCost'].toString()).toStringAsFixed(2)}",
    //                                                               style: const TextStyle(
    //                                                                   fontWeight:
    //                                                                       FontWeight
    //                                                                           .bold))
    //                                                         ]),
    //                                                     Row(
    //                                                         mainAxisAlignment:
    //                                                             MainAxisAlignment
    //                                                                 .spaceBetween,
    //                                                         children: [
    //                                                           const Text(
    //                                                               "Service fee:"),
    //                                                           Text(
    //                                                               "\$${double.parse(widget.data['payment']['serviceFee'].toString()).toStringAsFixed(2)}",
    //                                                               style: const TextStyle(
    //                                                                   fontWeight:
    //                                                                       FontWeight
    //                                                                           .bold))
    //                                                         ]),
    //                                                     const Divider(),
    //                                                     Row(
    //                                                         mainAxisAlignment:
    //                                                             MainAxisAlignment
    //                                                                 .spaceBetween,
    //                                                         children: [
    //                                                           const Text(
    //                                                               "Total:"),
    //                                                           Text(
    //                                                               "\$${double.parse((widget.data['payment']['driverCost'] + widget.data['payment']['serviceFee']).toString()).toStringAsFixed(2)}",
    //                                                               style: const TextStyle(
    //                                                                   fontWeight:
    //                                                                       FontWeight
    //                                                                           .bold))
    //                                                         ]),
    //                                                   ]))),
    //                               OutlinedButton(
    //                                   onPressed: () {
    //                                     if (!paymentInProgress) {
    //                                       setState(() {
    //                                         paymentInProgress = true;
    //                                       });
    //                                       initPaymentSheet(context,
    //                                           amount: double.parse((widget
    //                                                                   .data[
    //                                                               'payment']
    //                                                           [
    //                                                           'driverCost'] +
    //                                                       widget.data[
    //                                                               'payment']
    //                                                           [
    //                                                           'serviceFee'])
    //                                                   .toString()) *
    //                                               100,
    //                                           success:
    //                                               (response) async {
    //                                         await FirebaseFirestore
    //                                             .instance
    //                                             .collection('rides')
    //                                             .doc(widget
    //                                                 .data['rideID'])
    //                                             .update({
    //                                           'passengers': [
    //                                             {
    //                                               'uid': FirebaseAuth
    //                                                   .instance
    //                                                   .currentUser
    //                                                   ?.uid,
    //                                               'pickup': widget
    //                                                   .data['pickup'],
    //                                               'dropoff': widget
    //                                                   .data['dropoff'],
    //                                               'payment': {
    //                                                 'serviceFee': widget
    //                                                             .data[
    //                                                         'payment']
    //                                                     ['serviceFee'],
    //                                                 'driverFee': widget
    //                                                             .data[
    //                                                         'payment']
    //                                                     ['driverCost'],
    //                                                 'paymentID': jsonDecode(
    //                                                         response)[
    //                                                     'paymentIntent']
    //                                               },
    //                                               'times': widget
    //                                                   .data['times']
    //                                             }
    //                                           ]
    //                                         });
    //                                         setState(() {
    //                                           paymentInProgress = false;
    //                                         });
    //                                         Navigator.pop(context);
    //                                       }, error: (e) {
    //                                         setState(() {
    //                                           paymentInProgress = false;
    //                                         });
    //                                       });
    //                                     }
    //                                   },
    //                                   style: OutlinedButton.styleFrom(
    //                                       side: BorderSide.none,
    //                                       backgroundColor:
    //                                           Colors.green),
    //                                   child: Row(
    //                                       mainAxisAlignment:
    //                                           MainAxisAlignment.center,
    //                                       children: paymentInProgress
    //                                           ? [
    //                                               const SizedBox(
    //                                                   height: 20,
    //                                                   width: 20,
    //                                                   child:
    //                                                       CircularProgressIndicator(
    //                                                     color: Colors
    //                                                         .white,
    //                                                     strokeWidth:
    //                                                         2.5,
    //                                                   ))
    //                                             ]
    //                                           : const [
    //                                               Text("Pay",
    //                                                   style: TextStyle(
    //                                                       color: Colors
    //                                                           .white)),
    //                                               SizedBox(width: 5),
    //                                               Icon(
    //                                                   Icons
    //                                                       .arrow_forward,
    //                                                   color:
    //                                                       Colors.white,
    //                                                   size: 20)
    //                                             ]))
    //                             ]))
    //                       ])))))
    // ]));
  }
}
