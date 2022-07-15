import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/custom/database.dart';
import 'package:hopper_flutter_app/custom/passbase.dart';
import 'package:passbase_flutter/passbase_flutter.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: PassbaseButton(
          onSubmitted: (identityAccessKey) {
            verifySubmitted(identityAccessKey);
          },
          onFinish: (authenticationKey) {
            verifyComplete(authenticationKey);
          },
          onError: (error) {
            verifyError(error);
          },
          width: 256,
          height: 55),
      // floatingActionButton: const FloatingActionButton.extended(
      //   onPressed: TESTaddRider,
      //   label: Text('Test database'),
      //   icon: Icon(Icons.data_array),
      // ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
