import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/custom/database.dart';
import 'package:hopper_flutter_app/custom/passbase.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';
import 'package:passbase_flutter/passbase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class identityAuth extends StatelessWidget {
  const identityAuth({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    PassbaseSDK.prefillUserEmail = FirebaseAuth.instance.currentUser?.email;

    return SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Icon(Icons.check_circle_outline_rounded,
                  size: 110, color: Colors.blue.shade700)),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Before you enroll to become a driver you first have to take part in a identity verification test. This is to ensure the safety and security of our passengers",
                        style: themeData.textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      Text(
                          "Before you start make sure you meet the following requirements\n\n• Valid drivers licence\n• 22 years +\n",
                          textAlign: TextAlign.center,
                          style: themeData.textTheme.bodyMedium),
                    ],
                  ))),
          const Divider(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: PassbaseButton(
                height: 75,
                width: 100,
                onSubmitted: (identityAccessKey) {
                  verifySubmitted(identityAccessKey);
                },
                onFinish: (identityAccessKey) {
                  verifyComplete(identityAccessKey);
                },
              )),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: TextButton(
                  onPressed: () {},
                  child: Text("Terms of service",
                      style: themeData.textTheme.subtitle2,
                      textAlign: TextAlign.center)))
        ]));
  }
}
