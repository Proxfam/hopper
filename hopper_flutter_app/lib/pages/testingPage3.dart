import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';
import 'package:hopper_flutter_app/pages/testingPage2.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:hopper_flutter_app/utils/data.dart';

import '../custom/borderBox.dart';

class testingPage3 extends StatefulWidget {
  const testingPage3({Key? key}) : super(key: key);

  @override
  State<testingPage3> createState() => _testingPage3State();
}

class _testingPage3State extends State<testingPage3> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    const double padding = 25;

    final origin = TextEditingController();
    final destination = TextEditingController();

    return Scaffold(
        drawer: menuDraw(),
        key: _key,
        body: SafeArea(
            bottom: false,
            child: SizedBox(
                height: size.height,
                width: size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(color: COLOR_GREY),
                    Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      child: Column(children: <Widget>[
                        Container(
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0)),
                                color: COLOR_WHITE),
                            child: Padding(
                                padding: const EdgeInsets.all(padding),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    BorderBox(
                                      height: 50,
                                      width: 50,
                                      padding: const EdgeInsets.all(8.0),
                                      callback: menu,
                                      child: const Icon(Icons.menu,
                                          color: PRIMARY_COLOR),
                                    ),
                                    Text("Hopper",
                                        style: themeData.textTheme.headline1),
                                    const SizedBox(height: 50, width: 50)
                                  ],
                                ))),
                        Padding(
                            padding: const EdgeInsets.fromLTRB(
                                padding, 10, padding, 0),
                            child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: COLOR_WHITE),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: padding, vertical: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    TextField(
                                      controller: origin,
                                      decoration: const InputDecoration(
                                          labelText: "Origin"),
                                    ),
                                    TextField(
                                      controller: destination,
                                      decoration: InputDecoration(
                                          labelText: "Destination",
                                          suffixIcon: IconButton(
                                              onPressed: search,
                                              icon: const Icon(Icons.send))),
                                    )
                                  ],
                                ))),
                      ]),
                    ),
                    Positioned(
                        bottom: padding,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: padding),
                          child: RouteCard(itemData: RE_DATA[0]),
                        )),
                  ],
                ))));
  }

  void menu() {
    _key.currentState!.openDrawer();
  }

  void settings() {}

  void search() {
    print("SHIT");
  }
}
