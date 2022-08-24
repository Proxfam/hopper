import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:hopper_flutter_app/pages/mainPages/mapWidgets.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

class ridesPage extends StatefulWidget {
  const ridesPage({Key? key}) : super(key: key);

  @override
  State<ridesPage> createState() => _ridesPageState();
}

class _ridesPageState extends State<ridesPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      StreamBuilder<QuerySnapshot>(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Upcoming rides',
                                  style: TextStyle(
                                      fontSize: 31,
                                      fontWeight: FontWeight.bold,
                                      color: NIGHTMODE ? Colors.white : null)),
                              Row(children: const [
                                Text("See all",
                                    style: TextStyle(color: Colors.blue)),
                                Icon(Icons.arrow_forward, color: Colors.blue)
                              ])
                            ])),
                    Column(
                        children: snapshot.data!.docs.map((e) {
                      try {
                        for (var passenger in (e.data()
                            as Map<String, dynamic>)['passengers']) {
                          if (passenger['uid'] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            return enrolledRide(data: {
                              'rideData': e.data(),
                              'passengerData': passenger
                            });
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                      } catch (e) {
                        print("no passengers");
                      }
                      return const SizedBox.shrink();
                    }).toList())
                  ]);
            } else {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Upcoming rides',
                                  style: TextStyle(
                                      fontSize: 31,
                                      fontWeight: FontWeight.bold,
                                      color: NIGHTMODE ? Colors.white : null)),
                              Row(children: const [
                                Text("See all",
                                    style: TextStyle(color: Colors.blue)),
                                Icon(Icons.arrow_forward, color: Colors.blue)
                              ])
                            ]))
                  ]);
            }
          },
          stream: FirebaseFirestore.instance.collection('rides').snapshots()),
      StreamBuilder<QuerySnapshot>(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.hasData) {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Past rides',
                                  style: TextStyle(
                                      fontSize: 31,
                                      fontWeight: FontWeight.bold,
                                      color: NIGHTMODE ? Colors.white : null)),
                              Row(children: const [
                                Text("See all",
                                    style: TextStyle(color: Colors.blue)),
                                Icon(Icons.arrow_forward, color: Colors.blue)
                              ])
                            ])),
                    Column(
                        children: snapshot.data!.docs.map((e) {
                      try {
                        for (var passenger in (e.data()
                            as Map<String, dynamic>)['passengers']) {
                          if (passenger['uid'] ==
                              FirebaseAuth.instance.currentUser!.uid) {
                            return enrolledRide(data: {
                              'rideData': e.data(),
                              'passengerData': passenger
                            });
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                      } catch (e) {
                        print("no passengers");
                      }
                      return const SizedBox.shrink();
                    }).toList())
                  ]);
            } else {
              return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Upcoming rides',
                                  style: TextStyle(
                                      fontSize: 31,
                                      fontWeight: FontWeight.bold,
                                      color: NIGHTMODE ? Colors.white : null)),
                              Row(children: const [
                                Text("See all",
                                    style: TextStyle(color: Colors.blue)),
                                Icon(Icons.arrow_forward, color: Colors.blue)
                              ])
                            ]))
                  ]);
            }
          },
          stream: FirebaseFirestore.instance
              .collection('archivedRides')
              .snapshots())
    ]);
  }
}
