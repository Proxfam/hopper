// import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

void testDatabase() async {
  // Create a new user with a first and last name
  final user = <String, dynamic>{
    "first": "Ada",
    "last": "Lovelace",
    "born": 1815
  };

// Add a new document with a generated ID
  await FirebaseFirestore.instance.collection("users").add(user).then(
      (DocumentReference doc) =>
          print('DocumentSnapshot added with ID: ${doc.id}'));
}
