import 'dart:core';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/classes/review.dart';

class Driver {
  var docref;
  String uid;
  double rating;
  Set reviews = <Review>{};
  String vehicle;
  double literPer100km;

  Driver(this.uid, this.rating, this.vehicle, this.literPer100km);

  void uploadToDb() {
    FirebaseFirestore.instance
        .collection('drivers')
        .add(toJson())
        .then((value) => docref = value);
  }

  void fetchFromDb() async {
    var query = await FirebaseFirestore.instance
        .collection('drivers')
        // .where('uid', isEqualTo: uid.toString())
        .get()
        .then((value) {});
  }

  void addReview(Review review) {
    reviews.add(review);
  }

  Map<String, dynamic> toJson() {
    Set formatReviews = {};
    for (var element in reviews) {
      formatReviews.add(element.toJson());
    }

    return {
      'uid': uid,
      'rating': rating,
      'reviews': formatReviews.toList(),
      'vehicle': vehicle,
      'literPer100km': literPer100km
    };
  }
}

Driver _createDriver(record) {
  Driver driver = Driver(record['uid'], record['rating'], record['vehicle'],
      record['literPer100km']);

  Set.from(record['reviews']).forEach((element) {
    driver.reviews.add(
        Review(element['uid'], element['rating'], element['body'], driver));
  });

  return driver;
}

Future<Driver> downloadDriverByUID(String uid) {
  return FirebaseFirestore.instance
      .collection('drivers')
      .where('uid', isEqualTo: uid.toString())
      .get()
      .then((value) {
    if (value.docs.isEmpty) {
      throw Exception("None found");
    } else if (value.docs.length > 1) {
      throw Exception("More than one found by UID");
    } else {
      Driver driver = _createDriver(value.docs[0].data());
      driver.docref = value.docs[0].reference;
      return driver;
    }
  });
}
