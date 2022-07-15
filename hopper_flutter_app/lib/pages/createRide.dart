import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';

class createRide extends StatefulWidget {
  const createRide({Key? key}) : super(key: key);

  @override
  State<createRide> createState() => _createRideState();
}

class _createRideState extends State<createRide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create ride"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        shadowColor: Colors.transparent,
      ),
      drawer: menuDraw(),
      body: Container(),
    );
  }
}
