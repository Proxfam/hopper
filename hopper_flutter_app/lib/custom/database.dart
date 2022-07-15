import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:passbase_flutter/passbase_flutter.dart';
import '../classes/driver.dart';
import '../classes/review.dart';
import '../classes/ride.dart';

import 'dart:developer' as dartDev;

import 'package:http/http.dart' as http;

const GCFauth =
    "eyJhbGciOiJSUzI1NiIsImtpZCI6IjJiMDllNzQ0ZDU4Yzk5NTVkNGYyNDBiNmE5MmY3YjM3ZmVhZDJmZjgiLCJ0eXAiOiJKV1QifQ.eyJpc3MiOiJhY2NvdW50cy5nb29nbGUuY29tIiwiYXpwIjoiNjE4MTA0NzA4MDU0LTlyOXMxYzRhbGczNmVybGl1Y2hvOXQ1Mm4zMm42ZGdxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiYXVkIjoiNjE4MTA0NzA4MDU0LTlyOXMxYzRhbGczNmVybGl1Y2hvOXQ1Mm4zMm42ZGdxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwic3ViIjoiMTE2MTk3MTk4Mzc5NjE4NzIxNjA0IiwiZW1haWwiOiJ2YW5ib3htQGdtYWlsLmNvbSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJhdF9oYXNoIjoidzBfTk8zMjBWZ1hvZXFnQUx4ZU4tdyIsImlhdCI6MTY1NTg4ODQ5MSwiZXhwIjoxNjU1ODkyMDkxLCJqdGkiOiJmZGU3MGJhZTBiOGUyZTA3NjU4ODQyYzZhOGE3MTkwNWU5NTYxZjllIn0.L4pkmfuMuXSIqOqmyYW481HFbWWEBcqfZgtBWzggEGNlTr_Hj-rRAFsfUdfOh97mqOdC7dHMwny7EiK8h1KIEAclgWUYEmgQt_6nFBe_mRy0OxzLv5Uozprv2ae9kbjFgsxPSGs_jx5GFpahPDxTHM2iAU5Bz_xtP5zOWO8JyNhY1OBMv6ZcCACZXc6o7p7m1xRWGlbVIUuX98--c1lNdI756YVIUWQhtb-CFSeuMNwLug3m10ZsN47WivxJxuhLQZR1NrIqv0IaM4RH5TUzo_eySfIA9kOOiFmOmc7GkLOwzAHmLoc4A2KQmBmsl9H9CMdZwuj9I6IAtPoNRmkNEg";

void TESTwriteToFirestore() async {
  Driver newDriver =
      Driver(FirebaseAuth.instance.currentUser!.uid, "Nice toyoda", 3.4);

  Review newReview1 = Review(FirebaseAuth.instance.currentUser!.uid, 3.5,
      "This is a cool thing", newDriver);
  Review newReview2 = Review(FirebaseAuth.instance.currentUser!.uid, 2.4,
      "I think it was a great Ride!", newDriver);
  Review newReview3 = Review(FirebaseAuth.instance.currentUser!.uid, 4.6,
      "It's a big pill to swallow", newDriver);

  newDriver.addReview(newReview1);
  newDriver.addReview(newReview2);
  newDriver.addReview(newReview3);

  // Add a new document with a generated ID
  await FirebaseFirestore.instance
      .collection("drivers")
      .doc(newDriver.uid)
      .set(newDriver.toJson());
}

void TESTrideClass() async {
  await FirebaseFirestore.instance.collection('drivers').get().then((doc) {
    Future<Driver> driver = downloadDriverByUID(doc.docs[0].data()['uid']);
    driver.then((value) {
      print(value.runtimeType);
      if (value.runtimeType == Driver) {
        Future<Ride> newRide = uploadRide(
            value,
            const LatLng(-45.031196115254865, 168.6629237476333),
            const LatLng(-45.021817784071686, 168.70084353200264));
        newRide.then((value) {
          //Do shit once ride is done
        });
      } else {
        throw Exception('Internal code error');
      }
    });
  });
}

// void TESTcreateUserDocument() async {
//   await FirebaseFirestore.instance
//       .collection("users")
//       .doc(FirebaseAuth.instance.currentUser?.uid.toString())
//       .set({
//     "firstName": "Kane",
//     "lastName": "Viggers",
//     "identityVerified": false,
//     "identityAccessKey": "0ae7af91-405e-4069-a74f-f979d1b12af9",
//     "defaultOrigin": "12 Alexander Place, Arrowtown",
//     "defaultDestination": "47 Red Oaks drive, Frankton"
//   });
// }

void TESTrideDownload() async {
  var query = await FirebaseFirestore.instance.collection('drivers').get();
  Ride ride = await downloadRideByUID(query.docs[0].data()['uid']);
}

void TESTcreateRide() async {
  var query = await FirebaseFirestore.instance.collection('drivers').get();
  Driver driver = await downloadDriverByUID(query.docs[0].data()['uid']);
  LatLng origin = const LatLng(-44.949367445738105, 168.84515006257595);
  LatLng destination = const LatLng(-45.02968880084788, 168.65722512202342);
  Ride ride = await uploadRide(driver, origin, destination);
}

void TESTaddRider() async {
  var query = await FirebaseFirestore.instance.collection('drivers').get();
  Driver driver = await downloadDriverByUID(query.docs[0].data()['uid']);
  Ride ride = await downloadRideByUID(driver.uid);

  var response = await http
      .post(
        Uri.parse(
            'https://us-central1-hopper-2.cloudfunctions.net/addRiderToRide'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $GCFauth'
        },
        body: jsonEncode(<String, String>{
          'driver': driver.uid,
          'origin': '12 Alexander place, Arrowtown',
          'destination': '47 Red oaks drive, Frankton'
        }),
      )
      .catchError((e) => print(e));

  print(response.body);
}

void searchRides(TextEditingController originController,
    TextEditingController destinationController) async {
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
          'destinationRadius': 7
        }),
      )
      .catchError((e) => print(e));
  print(response.body);
}
