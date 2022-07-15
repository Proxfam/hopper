import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:hopper_flutter_app/pages/maps/mapWidgets.dart';

class ridesPage extends StatefulWidget {
  const ridesPage({Key? key}) : super(key: key);

  @override
  State<ridesPage> createState() => _ridesPageState();
}

class _ridesPageState extends State<ridesPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.topCenter,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            const Card(child: Text("wait a minute")),
            const Card(child: Text("what the fuck is going on")),
            const Card(child: Text("what the fuck is going on")),
            Card(
                child: TextButton(
                    onPressed: () {
                      initPaymentSheet(context,
                          amount: 699, success: () {}, error: (e) {});
                    },
                    child: Text("Test me")))
          ],
        ));
  }
}
