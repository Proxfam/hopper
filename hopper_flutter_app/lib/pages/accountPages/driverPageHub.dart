import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/pages/accountPages/driverSettings.dart';

import '../identityAuth.dart';

class driverPageHub extends StatefulWidget {
  const driverPageHub({Key? key}) : super(key: key);

  @override
  State<driverPageHub> createState() => _driverPageHubState();
}

class _driverPageHubState extends State<driverPageHub> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    int selectedIndex = 0;

    final Stream<QuerySnapshot> _usersStream =
        FirebaseFirestore.instance.collection('users').snapshots();

    List<Widget> pages = [
      identityAuth(),
      driverSettings(),
      Scaffold(
          appBar: AppBar(
            title: Text("Driver settings",
                style: themeData.textTheme.headlineMedium),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.grey,
            shadowColor: Colors.transparent,
          ),
          body: const Center(child: Text("Identity Verification pending")))
    ];

    Future<Map<String, dynamic>?> getData() async {
      var query = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid.toString())
          .get();
      return query.data();
    }

    return StreamBuilder<QuerySnapshot>(
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var userFile;

            snapshot.data?.docs.forEach(
              (element) {
                if (element.id == FirebaseAuth.instance.currentUser?.uid) {
                  userFile = element.data();
                }
              },
            );

            return IndexedStack(
                index: userFile['identityVerified'], children: pages);
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          return Center(child: CircularProgressIndicator());
        },
        stream: _usersStream);
  }
}
