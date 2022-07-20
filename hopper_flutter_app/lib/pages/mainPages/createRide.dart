import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_google_places/flutter_google_places.dart';

class createRide extends StatefulWidget {
  const createRide({Key? key}) : super(key: key);

  @override
  State<createRide> createState() => _createRideState();
}

class _createRideState extends State<createRide> {
  TextEditingController text = TextEditingController();
  @override
  Widget build(BuildContext context) {
    text.addListener(
      () async {
        print(text.text);
      },
    );

    return Scaffold(
        body: SafeArea(
            child: Center(
                child: TextButton(
                    child: const Text("Test me"),
                    onPressed: () async {
                      await PlacesAutocomplete.show(
                          context: context,
                          apiKey: "AIzaSyArRqDMu_RbWCN6PxHpfrZzGvN9D2wABfs");
                    }))));
  }
}
