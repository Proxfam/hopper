import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hopper_flutter_app/custom/database.dart';
import 'package:hopper_flutter_app/pages/accountPages/accountPage.dart';
import 'package:hopper_flutter_app/pages/accountPages/accountSettings.dart';
import 'package:hopper_flutter_app/pages/home/welcomePage.dart';
import 'package:hopper_flutter_app/pages/identityAuth.dart';
import 'package:hopper_flutter_app/pages/login/loginPage.dart';
import 'package:hopper_flutter_app/pages/testingPage6.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:passbase_flutter/passbase_flutter.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  PassbaseSDK.initialize(
      publishableApiKey:
          "O8vmEcyTIdE64fc5PxCFvPX1UB46UXWhFlVLizREkUdAXuHZNfAGs26AtgdRjwPL");
  Stripe.publishableKey =
      "pk_test_51LFA2lJj1tNJdnFypx1Np4KpST982pUFPA9OlmFsbAuQTgrZYxa4IBLlPR71KYcem9FyjQdWx7rQSNpTCFUGc5nv00s22o35tQ";
  //initializeHERESDK();
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
          fontFamily: "Montserrat",
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: welcomePage());
  }
}
