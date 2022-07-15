import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/custom/loginAuth.dart';
import 'package:hopper_flutter_app/pages/accountPages/accountPage.dart';
import 'package:hopper_flutter_app/pages/login/createAccountPage.dart';
import 'package:hopper_flutter_app/pages/menuDraw.dart';
import 'package:hopper_flutter_app/pages/testingPage4.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

class loginPage extends StatefulWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    const double padding = 25;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    if (FirebaseAuth.instance.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    const accountPage(),
                transitionDuration: const Duration(seconds: 0)));
      });
    }

    return Scaffold(
      body: Container(
          padding: const EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnimatedTextKit(
                    totalRepeatCount: 1,
                    animatedTexts: <AnimatedText>[
                      TyperAnimatedText('Ride',
                          textStyle: themeData.textTheme.headline1,
                          speed: const Duration(milliseconds: 50)),
                      TyperAnimatedText('Save',
                          textStyle: themeData.textTheme.headline1,
                          speed: const Duration(milliseconds: 50)),
                      TyperAnimatedText('Share',
                          textStyle: themeData.textTheme.headline1,
                          speed: const Duration(milliseconds: 50)),
                      TyperAnimatedText('Care',
                          textStyle: themeData.textTheme.headline1,
                          speed: const Duration(milliseconds: 50)),
                      TyperAnimatedText('Hopper',
                          textStyle: themeData.textTheme.headline1,
                          speed: const Duration(milliseconds: 75))
                    ],
                  )),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                controller: emailController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email), labelText: "Email"),
              ),
              TextField(
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                controller: passwordController,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    labelText: "Password",
                    suffixIcon: IconButton(
                        onPressed: (() {
                          signInWithEmail(
                                  context, emailController, passwordController)
                              .then((value) {
                            if (value) {
                              setState(() {
                                [emailController, passwordController]
                                    .map((e) => e.clear());
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: ((context) =>
                                          const accountPage())));
                            }
                          });
                        }),
                        icon: const Icon(Icons.arrow_circle_right))),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const createAccountPage()));
                      },
                      child: const Text("Create new account")))
            ],
          )),
    );
  }
}
