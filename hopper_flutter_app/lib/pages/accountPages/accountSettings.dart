import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/accountPages/listitem.dart';
import 'package:hopper_flutter_app/pages/accountPages/profileInfomation.dart';

import '../identityAuth.dart';

class accountSettings extends StatefulWidget {
  const accountSettings({Key? key}) : super(key: key);

  @override
  State<accountSettings> createState() => _accountSettingsState();
}

class _accountSettingsState extends State<accountSettings> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Account settings",
              style: themeData.textTheme.headlineMedium),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Colors.grey.shade100),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          listitem(
                              icon: Icon(Icons.person, size: 30),
                              text: "Profile infomation",
                              linkedPage: profileInfomation())
                        ])))));
  }
}
