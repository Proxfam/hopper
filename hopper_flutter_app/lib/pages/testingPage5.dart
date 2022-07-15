import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:passbase_flutter/passbase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class testingPage5 extends StatelessWidget {
  const testingPage5({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stripe Demo App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () async {
                await initPaymentSheet(context,
                    amount: 699, success: () {}, error: (e) {});
              },
              child: const Text(
                'Test Stripe',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}
