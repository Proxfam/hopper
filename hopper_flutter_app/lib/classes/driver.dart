import 'dart:core';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/classes/review.dart';

class Driver {
  late DatabaseReference _id;
  String uid;
  double rating;
  Set reviews = <Review>{};
  String vehicle;
  double literPer100km;

  Driver(this.uid, this.rating, this.vehicle, this.literPer100km);

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

Driver createDriver(record) {
  Driver driver = Driver(record['uid'], record['rating'], record['vehicle'],
      record['literPer100km']);

  Set.from(record['reviews']).forEach((element) {
    driver.reviews.add(
        Review(element['uid'], element['rating'], element['body'], driver));
  });

  return driver;
}
