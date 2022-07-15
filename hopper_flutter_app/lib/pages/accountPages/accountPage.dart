import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/pages/accountPages/accountSettings.dart';
import 'package:hopper_flutter_app/pages/accountPages/driverPageHub.dart';
import 'package:hopper_flutter_app/pages/accountPages/listitem.dart';
import 'package:hopper_flutter_app/pages/identityAuth.dart';
import 'package:http/http.dart';

import '../menuDraw.dart';

class accountPage extends StatefulWidget {
  const accountPage({Key? key}) : super(key: key);

  @override
  State<accountPage> createState() => _accountPageState();
}

class _accountPageState extends State<accountPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    Future<Map<String, dynamic>?> getData() async {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid.toString())
          .get();
      return query.data();
    }

    return FutureBuilder(
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              var data = snapshot.data as Map<String, dynamic>;

              return Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.grey,
                    shadowColor: Colors.transparent,
                  ),
                  drawer: menuDraw(),
                  body: SafeArea(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(children: [
                        CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 50,
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.grey.shade100,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                              //"${snapshot.data!['firstName']} ${snapshot.data!['lastname']}",
                              "${data['firstName']} ${data['lastName']}",
                              style: themeData.textTheme.headline3),
                        )
                      ]),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      color: Colors.grey.shade100),
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: const [
                                        listitem(
                                            icon:
                                                Icon(Icons.settings, size: 30),
                                            text: "Account settings",
                                            linkedPage: accountSettings()),
                                        listitem(
                                            icon: Icon(Icons.directions_car,
                                                size: 30),
                                            text: "Driver settings",
                                            linkedPage: driverPageHub()),
                                        listitem(
                                            icon: Icon(
                                                Icons.access_time_rounded,
                                                size: 30),
                                            text: "Past rides",
                                            linkedPage: null)
                                      ]))))
                    ],
                  )));
            }

            if (snapshot.hasError) {
              return Scaffold(
                  body: Center(child: Text("Error: ${snapshot.error}")));
            }
          }

          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
        future: getData());
  }
}
