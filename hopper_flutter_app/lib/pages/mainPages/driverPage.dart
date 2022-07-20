import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/accountPages/listitem.dart';
import 'package:hopper_flutter_app/pages/mainPages/createRide.dart';

class driverPage extends StatefulWidget {
  const driverPage({Key? key}) : super(key: key);

  @override
  State<driverPage> createState() => _driverPageState();
}

class _driverPageState extends State<driverPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return SafeArea(
        child: Column(children: [
      Text("Driver page", style: themeData.textTheme.headline3),
      Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.grey.shade100),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        listitem(
                            icon: const Icon(Icons.add,
                                color: Colors.blue, size: 30),
                            text: "Create ride",
                            callback: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          const createRide())));
                            })
                      ]))))
    ]));
  }
}
