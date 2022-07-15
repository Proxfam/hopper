import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class driverPage extends StatefulWidget {
  const driverPage({Key? key}) : super(key: key);

  @override
  State<driverPage> createState() => _driverPageState();
}

class _driverPageState extends State<driverPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.directions_car), Text("Driver settings")])
        ]));
  }
}
