import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:hopper_flutter_app/utils/data.dart';

import '../custom/borderBox.dart';

class testingPage extends StatefulWidget {
  const testingPage({Key? key}) : super(key: key);

  @override
  State<testingPage> createState() => _testingPageState();
}

class _testingPageState extends State<testingPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double padding = 25;

    return Scaffold(
        body: SafeArea(
            child: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: padding),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BorderBox(
                              height: 50,
                              width: 50,
                              padding: const EdgeInsets.all(8.0),
                              callback: menu,
                              child:
                                  const Icon(Icons.menu, color: PRIMARY_COLOR),
                            ),
                            Text("Hopper",
                                style: themeData.textTheme.headline1),
                            BorderBox(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(8.0),
                              callback: settings,
                              child: const Icon(Icons.settings,
                                  color: PRIMARY_COLOR),
                            )
                          ],
                        )),
                    SizedBox(height: padding),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: COLOR_GREY)),
                    )),
                    Padding(
                        padding: EdgeInsets.fromLTRB(padding, 15, padding, 0),
                        child: RouteCard(itemData: RE_DATA[0]))
                  ],
                ))));
  }

  void menu() {}

  void settings() {}
}

class RouteCard extends StatelessWidget {
  const RouteCard({Key? key, this.itemData}) : super(key: key);

  final dynamic itemData;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.shade300),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(90.0),
                    child: Image.asset(
                      itemData['image'],
                      height: 75,
                      width: 75,
                      scale: 1,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  const Spacer(),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Kane Viggers",
                            style: themeData.textTheme.headline2),
                        Row(
                          children: const [
                            Icon(Icons.star),
                            Icon(Icons.star),
                            Icon(Icons.star),
                            Icon(Icons.star),
                            Icon(Icons.star_half)
                          ],
                        )
                      ]),
                  const Spacer(),
                  Text(
                    "\$6.00 NZD",
                    style: themeData.textTheme.headline4,
                  )
                ],
              ),
              const Divider(
                height: 10,
                color: COLOR_GREY,
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Text("Leave by", style: themeData.textTheme.bodyMedium),
                      Text(
                        "7:30 am",
                        style: themeData.textTheme.headline3,
                      )
                    ],
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text("Arrive by", style: themeData.textTheme.bodyMedium),
                      Text(
                        "8:15 am",
                        style: themeData.textTheme.headline3,
                      )
                    ],
                  ),
                  const Spacer(),
                  TextButton(
                      onPressed: (() => {}), child: const Text("Details"))
                ],
              )
            ],
          ),
        ));
  }
}
