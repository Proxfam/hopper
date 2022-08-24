import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/custom/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hopper_flutter_app/pages/mainPages/defaultPage.dart';

import '../../custom/loginAuth.dart';
import '../../main.dart';
import '../accountPages/accountPage.dart';
import '../login/createAccountPage.dart';

class welcomePage extends StatefulWidget {
  const welcomePage({Key? key}) : super(key: key);

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  bool move = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool? firstOpen;

  @override
  void dispose() async {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const defaultPage(),
                transitionDuration: const Duration(seconds: 0)));
      });
    }

    return FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data as SharedPreferences;
            if (data.getBool('firstOpen') == null ||
                data.getBool('firstOpen') == false) {
              data.setBool('firstOpen', true);

              return Scaffold(
                  body: Stack(children: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.purple,
                    Colors.blue,
                  ],
                ))),
                // Positioned(
                //     bottom: 200,
                //     right: 0,
                //     left: 0,
                //     child: TextButton(
                //         child: const Text("reset"),
                //         onPressed: () {
                //           data.setBool('firstOpen', false);
                //         })),
                AnimatedPositioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: move ? 150 : 0,
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.fastOutSlowIn,
                    child: Center(
                        child: AnimatedTextKit(
                      pause: const Duration(milliseconds: 500),
                      onFinished: () {
                        setState(() {
                          move = true;
                        });
                      },
                      totalRepeatCount: 1,
                      animatedTexts: <AnimatedText>[
                        RotateAnimatedText('Kia ora!',
                            textStyle: themeData.textTheme.headlineLarge,
                            duration: const Duration(milliseconds: 2000)),
                      ],
                    ))),
                AnimatedPositioned(
                    top: move ? 0 : -100,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.fastOutSlowIn,
                    child: Center(
                        child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 1500),
                            opacity: move ? 1 : 0,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: (Text("EnviroLink",
                                          style: themeData
                                              .textTheme.headlineLarge))),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    "Email",
                                                                icon: Icon(Icons
                                                                    .email)),
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                        autocorrect: false,
                                                        controller:
                                                            emailController),
                                                    TextField(
                                                        obscureText: true,
                                                        autocorrect: false,
                                                        enableSuggestions:
                                                            false,
                                                        controller:
                                                            passwordController,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    "Password",
                                                                icon: const Icon(
                                                                    Icons
                                                                        .password),
                                                                suffixIcon:
                                                                    IconButton(
                                                                        onPressed:
                                                                            (() {
                                                                          signInWithEmail(context, emailController, passwordController)
                                                                              .then((value) {
                                                                            if (value) {
                                                                              setState(() {
                                                                                [
                                                                                  emailController,
                                                                                  passwordController
                                                                                ].map((e) => e.clear());
                                                                              });
                                                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => const defaultPage())));
                                                                            }
                                                                          });
                                                                        }),
                                                                        icon: const Icon(
                                                                            Icons.arrow_circle_right)))),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        child: OutlinedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const createAccountPage()));
                                                            },
                                                            child: const Text(
                                                                "Create new account")))
                                                  ]))))
                                ]))))
              ]));
            } else if (data.getBool('firstOpen') == true) {
              return Scaffold(
                  body: Stack(children: <Widget>[
                Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.purple,
                    Colors.blue,
                  ],
                ))),
                Positioned(
                    bottom: 200,
                    right: 0,
                    left: 0,
                    child: OutlinedButton(
                        child: const Text("reset"),
                        onPressed: () {
                          print(data.getBool('firstOpen'));
                          data.setBool('firstOpen', false);
                          print(data.getBool('firstOpen'));
                        })),
                AnimatedTextKit(
                    pause: const Duration(microseconds: 0),
                    isRepeatingAnimation: false,
                    totalRepeatCount: 1,
                    animatedTexts: [
                      RotateAnimatedText('',
                          duration: const Duration(milliseconds: 200))
                    ],
                    onFinished: () {
                      setState(() {
                        move = true;
                      });
                    }),
                AnimatedPositioned(
                    top: move ? 0 : -100,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.fastOutSlowIn,
                    child: Center(
                        child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 1500),
                            opacity: move ? 1 : 0,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: (Text("EnviroLink",
                                          style: themeData
                                              .textTheme.headlineLarge))),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    TextField(
                                                        decoration:
                                                            const InputDecoration(
                                                                labelText:
                                                                    "Email",
                                                                icon: Icon(Icons
                                                                    .email)),
                                                        keyboardType:
                                                            TextInputType
                                                                .emailAddress,
                                                        autocorrect: false,
                                                        controller:
                                                            emailController),
                                                    TextField(
                                                        obscureText: true,
                                                        autocorrect: false,
                                                        enableSuggestions:
                                                            false,
                                                        controller:
                                                            passwordController,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText:
                                                                    "Password",
                                                                icon: const Icon(
                                                                    Icons
                                                                        .password),
                                                                suffixIcon:
                                                                    IconButton(
                                                                        onPressed:
                                                                            (() {
                                                                          signInWithEmail(context, emailController, passwordController)
                                                                              .then((value) {
                                                                            if (value) {
                                                                              setState(() {
                                                                                [
                                                                                  emailController,
                                                                                  passwordController
                                                                                ].map((e) => e.clear());
                                                                              });
                                                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => const accountPage())));
                                                                            }
                                                                          });
                                                                        }),
                                                                        icon: const Icon(
                                                                            Icons.arrow_circle_right)))),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        child: OutlinedButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              const createAccountPage()));
                                                            },
                                                            child: const Text(
                                                                "Create new account")))
                                                  ]))))
                                ]))))
              ]));
            }
          }
          return Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.purple,
              Colors.blue,
            ],
          )));
        }),
        future: SharedPreferences.getInstance());
  }
}
