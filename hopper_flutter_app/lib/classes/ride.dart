import 'dart:math';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'driver.dart';

class Ride {
  Driver driver;
  late double distance;
  LatLng origin;
  LatLng destination;
  List<LatLng> coords = [];
  Set stops = <LocationData>{};

  Ride(this.driver, this.origin, this.destination);

  Future createRoute() async {
    final GOOGLE_API_KEY = 'AIzaSyA6wfyquzmWj59qJNGP-j4sqIqV16cuAZs';
    //Get all LatLng values for route
    PolylineResult result = await PolylinePoints().getRouteBetweenCoordinates(
        GOOGLE_API_KEY,
        PointLatLng(origin.latitude as double, origin.longitude as double),
        PointLatLng(
            destination.latitude as double, destination.longitude as double));

    //Load into polylineCoordinates
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        coords.add(LatLng(point.latitude, point.longitude));
      });
    }

    distance = calculateDistance(origin.latitude, origin.longitude,
        destination.latitude, destination.longitude);
  }

  Map<String, dynamic> toJson() {
    return {
      'driver': driver.uid,
      'distance': distance,
      'origin': origin.toJson(),
      'destination': destination.toJson(),
      'coords': coords,
      'stops': stops.toList()
    };
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
