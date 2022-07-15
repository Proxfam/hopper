import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:passbase_flutter/passbase_flutter.dart';

void verifySubmitted(identityAccessKey) async {
  log(identityAccessKey);
  log(identityAccessKey.runtimeType.toString());
  log('sub');
}

void verifyComplete(identityAccessKey) async {
  log(identityAccessKey);
  log(identityAccessKey.runtimeType.toString());
  log('com');
  await FirebaseFirestore.instance
      .collection("users")
      .doc(FirebaseAuth.instance.currentUser?.uid.toString())
      .set({"identityAccessKey": identityAccessKey.toString()},
          SetOptions(merge: true));
}

void verifyError(error) {
  log(error);
}
