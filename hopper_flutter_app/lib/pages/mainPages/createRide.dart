import 'package:bottom_picker/bottom_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class createRide extends StatefulWidget {
  const createRide({Key? key}) : super(key: key);

  @override
  State<createRide> createState() => _createRideState();
}

class _createRideState extends State<createRide> {
  TextEditingController originController =
      TextEditingController(text: "17 Devon Street, Arrowtown");
  TextEditingController destinationController =
      TextEditingController(text: "New world, Frankton, Queenstown");

  bool fieldsValid = false;
  bool validDateTime = false;
  bool isLoading = false;
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    void checkFields() {
      if (originController.text.isNotEmpty &&
          destinationController.text.isNotEmpty &&
          validDateTime) {
        setState(() {
          fieldsValid = true;
        });
      } else {
        setState(() {
          fieldsValid = false;
        });
      }
    }

    void verifyFields() async {
      var response = await http.post(
          Uri.parse(
              "https://us-central1-hopper-2.cloudfunctions.net/createRide"),
          body: {
            "origin": originController.text,
            "destination": destinationController.text,
            "departureTime": selectedDateTime.toString(),
            "driver": FirebaseAuth.instance.currentUser!.uid
          });
      print(response.body);
      setState(() {
        isLoading = false;
      });
    }

    originController.addListener(() => checkFields());
    destinationController.addListener(() => checkFields());

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey,
          shadowColor: Colors.transparent,
        ),
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Create ride", style: themeData.textTheme.headline1),
                      LinearProgressIndicator(
                          backgroundColor: isLoading
                              ? Colors.grey.shade300
                              : Colors.transparent,
                          color: isLoading ? null : Colors.transparent),
                      TextField(
                          readOnly: isLoading,
                          decoration:
                              const InputDecoration(labelText: "Origin"),
                          controller: originController),
                      TextField(
                          readOnly: isLoading,
                          decoration:
                              const InputDecoration(labelText: "Destination"),
                          controller: destinationController),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              splashFactory: fieldsValid && !isLoading
                                  ? null
                                  : NoSplash.splashFactory,
                              backgroundColor: isLoading
                                  ? Colors.grey.shade200
                                  : Colors.transparent),
                          onPressed: () {
                            if (isLoading) {
                              return;
                            }
                            BottomPicker.dateTime(
                              onSubmit: (p0) {
                                setState(() {
                                  selectedDateTime = p0;
                                  validDateTime = true;
                                });
                                checkFields();
                              },
                              title: "Choose date and time",
                              minDateTime: DateTime.now(),
                            ).show(context);
                          },
                          child:
                              const Text("Choose date and time of departure")),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            isLoading = true;
                          });
                          verifyFields();
                        },
                        style: OutlinedButton.styleFrom(
                            splashFactory: fieldsValid && !isLoading
                                ? null
                                : NoSplash.splashFactory,
                            backgroundColor: fieldsValid && !isLoading
                                ? Colors.blue
                                : Colors.blue.shade200),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Validate",
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(Icons.check, color: Colors.white)
                            ]),
                      ),
                    ]))));
  }
}
