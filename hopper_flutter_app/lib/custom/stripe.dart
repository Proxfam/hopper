import 'dart:convert';
import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_stripe/flutter_stripe.dart';

Future<dynamic> initPaymentSheet(context,
    {required double amount,
    required Function success,
    required Function(Object) error}) async {
  try {
    // 1. create payment intent on the server
    final response = await http.post(
        Uri.parse(
            'https://us-central1-hopper-2.cloudfunctions.net/stripePayment'),
        body: {
          'email': FirebaseAuth.instance.currentUser!.email,
          'amount': amount.toString(),
        });

    final jsonResponse = jsonDecode(response.body);

    //2. initialize the payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: jsonResponse['paymentIntent'],
        merchantDisplayName: 'Hopper',
        customerId: jsonResponse['customer'],
        customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
        style: ThemeMode.light,
        testEnv: true,
        merchantCountryCode: 'NZ',
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    success(response.body);
  } catch (e) {
    error(e);
  }
}
