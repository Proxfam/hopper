import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

import 'menuDraw.dart';

class newRide extends StatefulWidget {
  const newRide({Key? key}) : super(key: key);

  @override
  State<newRide> createState() => _newRideState();
}

class _newRideState extends State<newRide> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    const double padding = 25;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Schedule ride",
            style: themeData.textTheme.headline2,
          ),
          backgroundColor: Colors.white,
          foregroundColor: PRIMARY_COLOR,
        ),
        drawer: menuDraw(),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  controller: TextEditingController(),
                  decoration: const InputDecoration(labelText: "Origin"),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  controller: TextEditingController(),
                  decoration: const InputDecoration(labelText: "Destination"),
                ),
              ],
            )));
  }
}
