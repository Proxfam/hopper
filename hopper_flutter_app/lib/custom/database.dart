import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../classes/driver.dart';
import '../classes/review.dart';
import '../classes/ride.dart';

void TESTwriteToFirestore() async {
  Driver newDriver =
      Driver(FirebaseAuth.instance.currentUser!.uid, 4.6, "Nice toyoda", 3.4);

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

void TESTreadFromFirestore() async {
  //TESTwriteToFirestore();

  await FirebaseFirestore.instance.collection('drivers').get().then((doc) {
    //print(doc.docs[0].data() as Map<String, dynamic>);

    Driver newDriver = createDriver(doc.docs[0]);
    print(newDriver.reviews.toList()[0].body);
  });
}

void TESTrideClass() async {
  await FirebaseFirestore.instance
      .collection('drivers')
      .get()
      .then((doc) async {
    Ride newRide = Ride(
        createDriver(doc.docs[0]),
        const LatLng(-45.031196115254865, 168.6629237476333),
        const LatLng(-45.021817784071686, 168.70084353200264));

    await newRide.createRoute().then((value) {
      FirebaseFirestore.instance.collection("rides").add(newRide.toJson());
    });
  });
}
