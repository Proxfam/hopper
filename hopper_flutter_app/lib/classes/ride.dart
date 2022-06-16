library dart.developer;

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'driver.dart';

class Ride {
  late var docref;
  Driver driver;
  late double distance;
  LatLng origin;
  LatLng destination;
  List<LatLng> coords = [];
  Set stops = <LocationData>{};

  Ride(this.driver, this.origin, this.destination);

  Map<String, dynamic> toJson() {
    return {
      'driver': driver.uid,
      'distance': distance,
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'stops': stops.toList()
    };
  }
}

double _getDistance(polylineCoordinates) {
  double totalDistance = 0;
  for (var i = 0; i < polylineCoordinates.length - 1; i++) {
    totalDistance += _calculateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude);
  }
  return totalDistance;
}

double _calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

Future<Ride> _createRide(Map<String, dynamic> record, List collections) async {
  Driver driver = await downloadDriverByUID(record['driver']);
  Ride ride = Ride(driver, LatLng(record['origin'][0], record['origin'][1]),
      LatLng(record['destination'][0], record['destination'][1]));
  ride.distance = record['distance'];
  collections.forEach((element) {
    ride.coords.add(LatLng(element.data()['lat'], element.data()['lng']));
  });
  return ride;
}

Future<Ride> downloadRideByUID(String uid) async {
  var query = await FirebaseFirestore.instance
      .collection('rides')
      .where('driver', isEqualTo: uid)
      .get();
  if (query.docs.isEmpty) {
    throw Exception("None found");
  } else if (query.docs.length > 1) {
    throw Exception("More than one found by UID");
  } else {
    var collections = await FirebaseFirestore.instance
        .collection('rides')
        .doc(query.docs[0].id)
        .collection('coords')
        .get();
    return _createRide(query.docs[0].data(), collections.docs);
  }
}

Future<Ride> uploadRide(driver, origin, destination) async {
  Ride ride = Ride(driver, origin, destination);
  const GOOGLE_API_KEY = 'AIzaSyA6wfyquzmWj59qJNGP-j4sqIqV16cuAZs';
  //Get all LatLng values for route
  PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
      GOOGLE_API_KEY,
      PointLatLng(origin.latitude as double, origin.longitude as double),
      PointLatLng(
          destination.latitude as double, destination.longitude as double));

  //Load into polylineCoordinates
  if (result.points.isNotEmpty) {
    result.points.forEach((PointLatLng point) {
      ride.coords.add(LatLng(point.latitude, point.longitude));
    });
  }

  ride.distance = _getDistance(ride.coords);
  FirebaseFirestore.instance
      .collection("rides")
      .add(ride.toJson())
      .then((value) {
    ride.docref = value;
    ride.coords.forEach((element) async {
      await FirebaseFirestore.instance
          .collection('rides/${value.id}/coords')
          .add({'lat': element.latitude, 'lng': element.longitude});
    });
    print('uploaded to database');
  });
  return ride;
}
