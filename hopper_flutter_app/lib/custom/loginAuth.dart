import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<bool> signInWithEmail(BuildContext context, TextEditingController email,
    TextEditingController password) async {
  void verifyEmail() async {
    //Still doesn't want to send me an email
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Verification email sent")));
    print('sent');
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
    TextEditingController password) async {
  try {
    if (firstName.text == "" || lastName.text == "") {
      throw FirebaseAuthException(code: 'invalid-name');
    }

    final credentials = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: email.text.trim(), password: password.text.trim());
    credentials.user!.updateDisplayName('${firstName.text} ${lastName.text}');
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Account created")));
    return true;
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
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
      default:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.code)));
    }
    return false;
  }
}
