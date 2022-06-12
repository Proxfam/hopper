import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../classes/driver.dart';
import '../classes/review.dart';

void TESTwriteToFirestore() async {
  Review newReview1 = Review(
      FirebaseAuth.instance.currentUser!.uid, 3.5, "This is a cool thing");
  Review newReview2 = Review(FirebaseAuth.instance.currentUser!.uid, 2.4,
      "I think it was a great Ride!");
  Review newReview3 = Review(FirebaseAuth.instance.currentUser!.uid, 4.6,
      "It's a big pill to swallow");

  Driver newDriver =
      Driver(FirebaseAuth.instance.currentUser!.uid, 4.6, "Nice toyoda", 3.4);

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
