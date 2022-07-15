import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:hopper_flutter_app/pages/accountPages/accountPage.dart';
import 'package:hopper_flutter_app/pages/createRide.dart';
import 'package:hopper_flutter_app/pages/home/welcomePage.dart';
import 'package:hopper_flutter_app/pages/login/loginPage.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

import '../main.dart';
import 'home/homePage.dart';

class menuDraw extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final TextStyle? currentTheme = themeData.textTheme.headline1;
    final drawTitle = TextStyle(
        color: COLOR_WHITE,
        fontWeight: currentTheme?.fontWeight,
        fontSize: currentTheme?.fontSize,
        fontFamily: "Montserrat");

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.purple,
                  Colors.blue,
                ],
              )),
              child: Text(
                'Hopper',
                style: drawTitle,
              )),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.blue),
            title: const Text('Create ride'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const createRide()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const mainPage()));
            },
          ),
          ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () => {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const accountPage()))
                  }),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const welcomePage()));
            },
          ),
          ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () => {Navigator.of(context).pop()})
        ],
      ),
    );
  }
}
