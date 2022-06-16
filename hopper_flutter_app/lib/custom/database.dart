import 'dart:developer';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../classes/driver.dart';
import '../classes/review.dart';
import '../classes/ride.dart';

import 'dart:developer' as dartDev;

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
      .add(newDriver.toJson())
      .then((DocumentReference doc) =>
          print('DocumentSnapshot added with ID: ${doc.id}'));
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
  final GOOGLE_API_KEY = 'AIzaSyA6wfyquzmWj59qJNGP-j4sqIqV16cuAZs';

  var query = await FirebaseFirestore.instance.collection('drivers').get();
  Driver driver = await downloadDriverByUID(query.docs[0].data()['uid']);
  Ride ride = await downloadRideByUID(driver.uid);

  DirectionsService.init(GOOGLE_API_KEY);

  await DirectionsService().route(
      DirectionsRequest(
          origin: '${ride.origin.latitude},${ride.origin.longitude}',
          destination:
              '${ride.destination.latitude},${ride.destination.longitude}',
          travelMode: const TravelMode('car'),
          transitOptions:
              TransitOptions(departureTime: DateTime(2022, 6, 18, 9))),
      (p0, p1) {
    p0.routes?[0].legs?.forEach((element) {
      print(element.startAddress);
      print(element.endAddress);
      print(element.distance?.text);
      print(element.duration?.text);
      print(element.durationInTraffic?.text);
      print(element.departureTime?.text);
      print(element.arrivalTime?.text);
    });
  });
}
