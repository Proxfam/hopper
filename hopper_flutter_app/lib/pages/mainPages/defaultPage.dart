import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/pages/accountPages/driverPageHub.dart';
import 'package:hopper_flutter_app/pages/mainPages/driverPage.dart';
import 'package:hopper_flutter_app/pages/mainPages/ridesPage.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:location/location.dart';

import 'dart:math' as math;
import 'package:http/http.dart' as http;

import '../../custom/database.dart';
import 'mapPage.dart';

class defaultPage extends StatefulWidget {
  const defaultPage({Key? key}) : super(key: key);

  @override
  State<defaultPage> createState() => _defaultPageState();
}

class _defaultPageState extends State<defaultPage> {
  int selectedIndex = 1;

  List<Widget> bodyWidgets = <Widget>[
    const driverPageHub(),
    const mapPage(),
    const ridesPage()
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    // TextEditingController originController = TextEditingController();
    // TextEditingController destinationController = TextEditingController();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: NIGHTMODE ? Colors.grey.shade900 : null,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // foregroundColor: Colors.grey.shade400,
          foregroundColor: [
            Colors.grey,
            Colors.white,
            Colors.grey
          ][selectedIndex],
          shadowColor: Colors.transparent,
        ),
        extendBodyBehindAppBar: true,
        drawer: menuDraw(),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: NIGHTMODE ? Colors.white.withAlpha(255) : null,
          unselectedItemColor: NIGHTMODE ? Colors.white.withAlpha(150) : null,
          backgroundColor: NIGHTMODE ? Colors.grey.shade900 : null,
          currentIndex: selectedIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.directions_car), label: "Drive"),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
            BottomNavigationBarItem(icon: Icon(Icons.route), label: "Rides")
          ],
          onTap: (i) {
            setState(() {
              selectedIndex = i;
            });
          },
        ),
        body: IndexedStack(
          // alignment: Alignment.top,
          index: selectedIndex,
          children: bodyWidgets,
        ));
  }
}
