import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/pages/testingPage3.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

final FirebaseAuth _auth = _auth;

Future<bool> signInMemory() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user == null ? false : true;
}

Future<bool> signInWithEmail(BuildContext context, TextEditingController email,
    TextEditingController password) async {
  void verifyEmail() async {
    User user = (_auth.currentUser!);
    user.reload();
    user.sendEmailVerification();
  }

  try {
    final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email.text, password: password.text);
    if (!credential.user!.emailVerified) {
      throw FirebaseAuthException(code: 'email-not-verified');
    }
    return true;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'user-not-found':
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user found with given email")));
        break;
      case 'wrong-password':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Incorrect password")));
        break;
      case 'email-not-verified':
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text("Email not verified"),
            action: SnackBarAction(
                label: 'Verify email',
                onPressed: verifyEmail,
                textColor: Colors.blue)));
        break;
      case 'invalid-email':
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Baddly formatted email")));
        break;
      default:
        print(e);
        break;
    }
    return false;
  }
}

Future<dynamic> createAccountWithEmail(
    BuildContext context,
    TextEditingController firstName,
    TextEditingController lastName,
    TextEditingController email,
    TextEditingController password,
    TextEditingController confPassword) async {
  try {
    if (firstName.text == "" || lastName.text == "") {
      throw FirebaseAuthException(code: 'invalid-name');
    } else if (confPassword.text != password.text) {
      throw FirebaseAuthException(code: 'password-does-not-match');
    }

    final credentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: email.text.trim(), password: password.text.trim());
    credentials.user!.updateDisplayName('${firstName.text} ${lastName.text}');
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Account created")));
    return true;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case 'weak-password':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Weak password")));
        break;
      case 'missing-email':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Email not provided")));
        break;
      case 'invalid-email':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Invalid email")));
        break;
      case 'invalid-name':
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Name required")));
        break;
      case 'email-already-in-use':
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email already in use")));
        break;
      case 'password-does-not-match':
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Passwords do not match")));
        break;
      default:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.code)));
    }
    return false;
  }
}
