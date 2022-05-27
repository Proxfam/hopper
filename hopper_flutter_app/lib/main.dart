import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/pages/landingPage.dart';
import 'package:hopper_flutter_app/pages/testingPage.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

void main() {
  runApp(const mainPage());
}

class mainPage extends StatelessWidget {
  const mainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = window.physicalSize.width;
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Hopper",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch()
              .copyWith(secondary: COLOR_DARK_BLUE, primary: PRIMARY_COLOR),
          textTheme: screenWidth < 500 ? TEXT_THEME_SMALL : TEXT_THEME_DEFAULT,
          fontFamily: "Montserrat ",
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const testingPage());
  }
}
