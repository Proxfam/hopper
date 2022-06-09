import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

import '../custom/borderBox.dart';

class landingPage extends StatefulWidget {
  const landingPage({Key? key}) : super(key: key);

  @override
  State<landingPage> createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final ThemeData themeData = Theme.of(context);
    final double padding = 25;

    return Scaffold(
        appBar: AppBar(title: Text("hello")),
        drawer: menuDraw(),
        body: SafeArea(
            child: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.menu, color: PRIMARY_COLOR),
                              callback: menu,
                            ),
                            Text("Hopper",
                                style: themeData.textTheme.headline1),
                            BorderBox(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(8.0),
                              child: Icon(Icons.settings, color: PRIMARY_COLOR),
                              callback: settings,
                            )
                          ],
                        )),
                    SizedBox(height: padding),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child:
                            Text('City', style: themeData.textTheme.bodyText2)),
                    const SizedBox(height: 10),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Text('San Francisco',
                            style: themeData.textTheme.headline1)),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: Divider(height: padding, color: COLOR_GREY)),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                            children: [
                          "Kane",
                          "Lily",
                          "Cam",
                          "Sophie",
                          "Emily",
                          "Jack",
                          "Will"
                        ].map((e) => ChoiceOption(text: e)).toList()))
                  ],
                ))));
  }

  void menu() {}

  void settings() {}
}

class ChoiceOption extends StatelessWidget {
  const ChoiceOption({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData themedata = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: COLOR_GREY.withAlpha(25),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      margin: const EdgeInsets.only(left: 25),
      child: Text(text, style: themedata.textTheme.headline5),
    );
  }
}
