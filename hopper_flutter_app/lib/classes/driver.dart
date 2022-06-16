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
  late double rating;
  Set reviews = <Review>{};
  String vehicle;
  double literPer100km;

  Driver(this.uid, this.vehicle, this.literPer100km, [this.rating = 0]);

  void updateDriver() async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(docref)
        .update(toJson());
  }

  void deleteDriver() async {
    await FirebaseFirestore.instance.collection('drivers').doc(docref).delete();
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
  Driver driver = Driver(record['uid'], record['vehicle'],
      record['literPer100km'], record['rating']);

  Set.from(record['reviews']).forEach((element) {
    driver.reviews.add(
        Review(element['uid'], element['rating'], element['body'], driver));
  });

  return driver;
}

Future<Driver> downloadDriverByUID(String uid) {
  return FirebaseFirestore.instance
      .collection('drivers')
      .where('uid', isEqualTo: uid)
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

Future<Driver> uploadDriver(String uid, String vehicle, double literPer100km) {
  Driver driver = Driver(uid, vehicle, literPer100km);
  return FirebaseFirestore.instance
      .collection('drivers')
      .add(driver.toJson())
      .then((value) {
    driver.docref = value;
    return driver;
  });
}
