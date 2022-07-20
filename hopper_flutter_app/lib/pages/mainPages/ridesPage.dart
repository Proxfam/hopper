import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:hopper_flutter_app/pages/mainPages/mapWidgets.dart';

class ridesPage extends StatefulWidget {
  const ridesPage({Key? key}) : super(key: key);

  @override
  State<ridesPage> createState() => _ridesPageState();
}

class _ridesPageState extends State<ridesPage> {
  // Container(
  //       padding: EdgeInsets.symmetric(horizontal: 20),
  //       alignment: Alignment.topCenter,
  //       child: ListView(
  //         scrollDirection: Axis.vertical,
  //         children: [
  //           rideResult(data: data)
  //           const Card(child: Text("wait a minute")),
  //           const Card(child: Text("what the fuck is going on")),
  //           const Card(child: Text("what the fuck is going on")),
  //           Card(
  //               child: TextButton(
  //                   onPressed: () {
  //                     initPaymentSheet(context,
  //                         amount: 699, success: () {}, error: (e) {});
  //                   },
  //                   child: Text("Test me")))
  //         ],
  //       ));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
        builder: ((context, rideSnapshot) {
          if (rideSnapshot.hasData) {
            var selectedRides = [];

            return ListView.builder(
                itemCount: rideSnapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  return enrolledRide(content: rideSnapshot, index: index);
                });

            // return ListView(
            //     children: snapshot.data?.docs.map((e) async {
            //   return StreamBuilder<QuerySnapshot>(
            //       builder: (context, snapshot) {
            //         if (snapshot.hasData) {}
            //         return SizedBox.shrink();
            //       },
            //       stream: FirebaseFirestore.instance
            //           .collection('rides')
            //           .doc(e.id)
            //           .collection('passengers')
            //           .snapshots());
            // }).toList() as List<Widget>);
          }
          return const SizedBox.shrink();
        }),
        future: FirebaseFirestore.instance.collection('rides').get());
  }
}
