import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/custom/loginAuth.dart';
import 'package:hopper_flutter_app/pages/testingPage3.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

class createAccountPage extends StatefulWidget {
  const createAccountPage({Key? key}) : super(key: key);

  @override
  State<createAccountPage> createState() => _createAccountPageState();
}

class _createAccountPageState extends State<createAccountPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    const double padding = 25;

    final FnameController = TextEditingController();
    final LnameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    FnameController.text = 'Kane';
    LnameController.text = 'Viggers';
    emailController.text = 'kane.viggers@gmail.com';
    passwordController.text = 'tomtom11tomtom11';

    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: PRIMARY_COLOR,
            title: const Text("Hopper"),
            titleTextStyle: themeData.textTheme.headline1),
        body: Container(
            padding: const EdgeInsets.symmetric(horizontal: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Create account",
                    style: themeData.textTheme.headline1,
                  ),
                ),
                Row(children: [
                  Flexible(
                      child: TextField(
                    controller: FnameController,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person),
                        labelText: "First name"),
                  )),
                  SizedBox(width: 10),
                  Flexible(
                      child: TextField(
                          controller: LnameController,
                          decoration:
                              const InputDecoration(labelText: "Last name")))
                ]),
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
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password), labelText: "Password"),
                ),
                TextField(
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.password),
                      labelText: "Confirm password"),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: OutlinedButton(
                        onPressed: () {
                          createAccountWithEmail(
                                  context,
                                  FnameController,
                                  LnameController,
                                  emailController,
                                  passwordController)
                              .then((value) {
                            if (value != null && value) {
                              setState(() {
                                [
                                  FnameController,
                                  LnameController,
                                  emailController,
                                  passwordController
                                ].map((e) => e.clear());
                              });
                              Navigator.pop(context);
                            }
                          });
                        },
                        child: const Text("Create account")))
              ],
            )));
  }
}
