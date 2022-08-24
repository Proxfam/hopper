import 'dart:convert';
import 'dart:typed_data';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/widgets/bottom_picker_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_directions_api/google_directions_api.dart';
import 'package:google_geocoding/google_geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:math' as Math;

import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:hopper_flutter_app/pages/mainPages/rideDetails.dart';
import 'package:hopper_flutter_app/utils/contants.dart';
import 'package:location/location.dart' as LocationManager;

class rideSearcher extends StatefulWidget {
  rideSearcher(
      {Key? key,
      required this.originController,
      required this.destinationController,
      required this.callback,
      required this.isLoading,
      required this.expanded})
      : super(key: key);

  final TextEditingController originController;
  final TextEditingController destinationController;
  bool isLoading;
  bool expanded;
  final Function(DateTime) callback;
  @override
  State<rideSearcher> createState() => _rideSearcherState();
}

class _rideSearcherState extends State<rideSearcher> {
  bool submittedTime = false;
  bool isLoadingLocation = false;
  late DateTime departureTime;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        duration: Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        height: 190,
        bottom: MediaQuery.of(context).viewInsets.bottom -
            (MediaQuery.of(context).viewInsets.bottom / 100 * 25) -
            (widget.expanded ? 0 : 170),
        // bottom: MediaQuery.of(context).viewInsets.bottom -
        //     (MediaQuery.of(context).viewInsets.bottom / 100 * 25),
        left: 0,
        right: 0,
        child: Row(children: [
          Flexible(
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: ClipRRect(
                          child: OverflowBox(
                              maxHeight: double.infinity,
                              alignment: Alignment.topCenter,
                              child: Column(children: [
                                Row(children: [
                                  Flexible(
                                      child: TextField(
                                          onTap: () {
                                            if (widget.originController.text ==
                                                'Current location') {
                                              widget.originController.text = '';
                                            }
                                          },
                                          controller: widget.originController,
                                          decoration: InputDecoration(
                                            labelText: "Origin",
                                            suffixIcon: IconButton(
                                                onPressed: () async {
                                                  if (isLoadingLocation) {
                                                    return;
                                                  }
                                                  setState(() {
                                                    isLoadingLocation = true;
                                                  });
                                                  try {
                                                    var coord =
                                                        await GeolocatorPlatform
                                                            .instance
                                                            .getCurrentPosition();
                                                    var location =
                                                        await placemarkFromCoordinates(
                                                            coord.latitude,
                                                            coord.longitude);
                                                    widget.originController
                                                            .text =
                                                        "${location.first.street}";
                                                  } catch (e) {
                                                    print(e);
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                            content: Text(
                                                                "Error fetching location: ${e.toString()}")));
                                                  } finally {
                                                    setState(() {
                                                      isLoadingLocation = false;
                                                    });
                                                  }
                                                },
                                                //const Icon(Icons.my_location_rounded)
                                                // SizedBox(
                                                //     height: 25,
                                                //     width: 25,
                                                //     child: CircularProgressIndicator(
                                                //       strokeWidth: 3,
                                                //       color: Colors.grey,
                                                //     ))
                                                icon: isLoadingLocation
                                                    ? const SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth: 3,
                                                          color: Colors.grey,
                                                        ))
                                                    : const Icon(Icons
                                                        .my_location_rounded)),
                                          ))),
                                  const SizedBox(width: 10),
                                  TextButton(
                                      style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.grey.shade50),
                                      onPressed: () async {
                                        // await showDatePicker(
                                        //   context: context,
                                        //   initialDate:
                                        //       submittedTime ? departureTime : DateTime.now(),
                                        //   firstDate: DateTime.now(),
                                        //   lastDate: DateTime.now().add(Duration(days: 365)),
                                        //   helpText: 'Select a date',
                                        // ).then((value) {
                                        //   if (value != null) {
                                        //     selectedDate = value;
                                        //   }
                                        // });

                                        // await showTimePicker(
                                        //   helpText: "Pick time of departure",
                                        //   initialEntryMode: TimePickerEntryMode.input,
                                        //   context: context,
                                        //   initialTime: TimeOfDay.now(),
                                        // ).then((value) {
                                        //   if (value != null) {
                                        //     selectedTime = value;
                                        //   }
                                        // });

                                        // if (selectedDate != null || selectedTime != null) {
                                        //   setState(() {
                                        //     departureTime = selectedDate!.add(Duration(
                                        //         hours: selectedTime!.hour,
                                        //         minutes: selectedTime!.minute));
                                        //     submittedTime = true;
                                        //   });
                                        // }

                                        BottomPicker.dateTime(
                                                dismissable: true,
                                                initialDateTime: submittedTime
                                                    ? departureTime
                                                    : null,
                                                onSubmit: ((p0) {
                                                  setState(() {
                                                    departureTime = p0;
                                                    submittedTime = true;
                                                  });
                                                }),
                                                onClose: () {
                                                  setState(() {
                                                    submittedTime = false;
                                                  });
                                                },
                                                title: "Choose departure time",
                                                minDateTime: DateTime.now())
                                            .show(context);
                                      },
                                      child: Row(children: [
                                        const Icon(Icons.edit_calendar_rounded,
                                            color: Colors.grey),
                                        const SizedBox(width: 10),
                                        Text(
                                            submittedTime
                                                ? DateTime.now()
                                                            .difference(
                                                                departureTime)
                                                            .inDays <
                                                        -6
                                                    ? "${departureTime.day}/${departureTime.month} - ${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().length == 1 ? "0${departureTime.minute}" : departureTime.minute} ${departureTime.hour > 12 ? "PM" : "AM"}"
                                                    : "${(departureTime.weekday == 1) ? "Mon" : (departureTime.weekday == 2) ? "Tue" : (departureTime.weekday == 3) ? "Wed" : (departureTime.weekday == 4) ? "Thu" : (departureTime.weekday == 5) ? "Fri" : (departureTime.weekday == 6) ? "Sat" : "Sun"} - ${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().length == 1 ? "0${departureTime.minute}" : departureTime.minute} ${departureTime.hour > 12 ? "PM" : "AM"}"
                                                : "Now",
                                            style: const TextStyle(
                                                color: Colors.grey))
                                      ])),
                                ]),
                                Row(children: [
                                  Flexible(
                                    child: TextField(
                                        controller:
                                            widget.destinationController,
                                        decoration: InputDecoration(
                                            labelText: "Destination",
                                            suffixIcon: IconButton(
                                                onPressed: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  if (isLoadingLocation) return;
                                                  if (widget.originController
                                                              .text !=
                                                          "" &&
                                                      widget.destinationController
                                                              .text !=
                                                          "") {
                                                    widget.isLoading = true;
                                                    if (submittedTime) {
                                                      widget.callback(
                                                          departureTime);
                                                    } else {
                                                      departureTime =
                                                          DateTime.now();
                                                      widget.callback(
                                                          departureTime);
                                                    }
                                                  }
                                                },
                                                icon: widget.isLoading
                                                    ? const SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child:
                                                            CircularProgressIndicator(
                                                                strokeWidth: 3,
                                                                color: Colors
                                                                    .grey))
                                                    : Icon(
                                                        isLoadingLocation
                                                            ? Icons.search_off
                                                            : Icons.search,
                                                        size: 30)))),
                                  )
                                ])
                              ]))))))
        ]));
  }

  // @override
  // Widget build(BuildContext context) {
  //   return AnimatedPositioned(
  //       curve: Curves.fastOutSlowIn,
  //       height: 212,
  //       bottom: 0,
  //       left: 0,
  //       right: 0,
  //       duration: Duration(milliseconds: 500),
  //       child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
  //           child: Container(
  //               decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: BorderRadius.circular(20)),
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //               child: Column(children: [
  //                 Row(children: [
  //                   Flexible(
  //                       child: TextField(
  //                           onTap: () {
  //                             if (widget.originController.text ==
  //                                 'Current location') {
  //                               widget.originController.text = '';
  //                             }
  //                           },
  //                           controller: widget.originController,
  //                           decoration: InputDecoration(
  //                             labelText: "Origin",
  //                             suffixIcon: IconButton(
  //                                 onPressed: () async {
  //                                   if (isLoadingLocation) {
  //                                     return;
  //                                   }
  //                                   setState(() {
  //                                     isLoadingLocation = true;
  //                                   });
  //                                   FocusScope.of(context).unfocus();
  //                                   try {
  //                                     var coord = await GeolocatorPlatform
  //                                         .instance
  //                                         .getCurrentPosition();
  //                                     var location =
  //                                         await placemarkFromCoordinates(
  //                                             coord.latitude, coord.longitude);
  //                                     widget.originController.text =
  //                                         "${location.first.street}";
  //                                   } catch (e) {
  //                                     print(e);
  //                                     ScaffoldMessenger.of(context)
  //                                         .showSnackBar(SnackBar(
  //                                             content: Text(
  //                                                 "Error fetching location: ${e.toString()}")));
  //                                   } finally {
  //                                     setState(() {
  //                                       isLoadingLocation = false;
  //                                     });
  //                                   }
  //                                 },
  //                                 //const Icon(Icons.my_location_rounded)
  //                                 // SizedBox(
  //                                 //     height: 25,
  //                                 //     width: 25,
  //                                 //     child: CircularProgressIndicator(
  //                                 //       strokeWidth: 3,
  //                                 //       color: Colors.grey,
  //                                 //     ))
  //                                 icon: isLoadingLocation
  //                                     ? const SizedBox(
  //                                         height: 25,
  //                                         width: 25,
  //                                         child: CircularProgressIndicator(
  //                                           strokeWidth: 3,
  //                                           color: Colors.grey,
  //                                         ))
  //                                     : const Icon(Icons.my_location_rounded)),
  //                           ))),
  //                   const SizedBox(width: 10),
  //                   TextButton(
  //                       style: OutlinedButton.styleFrom(
  //                           backgroundColor: Colors.grey.shade50),
  //                       onPressed: () async {
  //                         // await showDatePicker(
  //                         //   context: context,
  //                         //   initialDate:
  //                         //       submittedTime ? departureTime : DateTime.now(),
  //                         //   firstDate: DateTime.now(),
  //                         //   lastDate: DateTime.now().add(Duration(days: 365)),
  //                         //   helpText: 'Select a date',
  //                         // ).then((value) {
  //                         //   if (value != null) {
  //                         //     selectedDate = value;
  //                         //   }
  //                         // });

  //                         // await showTimePicker(
  //                         //   helpText: "Pick time of departure",
  //                         //   initialEntryMode: TimePickerEntryMode.input,
  //                         //   context: context,
  //                         //   initialTime: TimeOfDay.now(),
  //                         // ).then((value) {
  //                         //   if (value != null) {
  //                         //     selectedTime = value;
  //                         //   }
  //                         // });

  //                         // if (selectedDate != null || selectedTime != null) {
  //                         //   setState(() {
  //                         //     departureTime = selectedDate!.add(Duration(
  //                         //         hours: selectedTime!.hour,
  //                         //         minutes: selectedTime!.minute));
  //                         //     submittedTime = true;
  //                         //   });
  //                         // }

  //                         BottomPicker.dateTime(
  //                                 dismissable: true,
  //                                 initialDateTime:
  //                                     submittedTime ? departureTime : null,
  //                                 onSubmit: ((p0) {
  //                                   setState(() {
  //                                     departureTime = p0;
  //                                     submittedTime = true;
  //                                   });
  //                                 }),
  //                                 onClose: () {
  //                                   setState(() {
  //                                     submittedTime = false;
  //                                   });
  //                                 },
  //                                 title: "Choose departure time",
  //                                 minDateTime: DateTime.now())
  //                             .show(context);
  //                       },
  //                       child: Row(children: [
  //                         const Icon(Icons.edit_calendar_rounded,
  //                             color: Colors.grey),
  //                         const SizedBox(width: 10),
  //                         Text(
  //                             submittedTime
  //                                 ? DateTime.now()
  //                                             .difference(departureTime)
  //                                             .inDays <
  //                                         -6
  //                                     ? "${departureTime.day}/${departureTime.month} - ${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().length == 1 ? "0${departureTime.minute}" : departureTime.minute} ${departureTime.hour > 12 ? "PM" : "AM"}"
  //                                     : "${(departureTime.weekday == 1) ? "Mon" : (departureTime.weekday == 2) ? "Tue" : (departureTime.weekday == 3) ? "Wed" : (departureTime.weekday == 4) ? "Thu" : (departureTime.weekday == 5) ? "Fri" : (departureTime.weekday == 6) ? "Sat" : "Sun"} - ${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().length == 1 ? "0${departureTime.minute}" : departureTime.minute} ${departureTime.hour > 12 ? "PM" : "AM"}"
  //                                 : "Now",
  //                             style: const TextStyle(color: Colors.grey))
  //                       ])),
  //                 ]),
  //                 Row(children: [
  //                   Flexible(
  //                     child: TextField(
  //                         controller: widget.destinationController,
  //                         decoration: InputDecoration(
  //                             labelText: "Destination",
  //                             suffixIcon: IconButton(
  //                                 onPressed: () {
  //                                   if (isLoadingLocation) return;
  //                                   widget.isLoading = true;
  //                                   if (submittedTime) {
  //                                     widget.callback(departureTime);
  //                                   } else {
  //                                     departureTime = DateTime.now();
  //                                     widget.callback(departureTime);
  //                                   }
  //                                   //submittedTime = false;
  //                                 },
  //                                 icon: widget.isLoading
  //                                     ? const SizedBox(
  //                                         height: 25,
  //                                         width: 25,
  //                                         child: CircularProgressIndicator(
  //                                             strokeWidth: 3,
  //                                             color: Colors.grey))
  //                                     : Icon(
  //                                         isLoadingLocation
  //                                             ? Icons.search_off
  //                                             : Icons.search,
  //                                         size: 30)))),
  //                   ),
  //                 ]),
  //                 Flexible(
  //                     child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                       ActionChip(
  //                           backgroundColor: Colors.grey.shade200,
  //                           shadowColor: Colors.transparent,
  //                           label: Row(children: [
  //                             Icon(Icons.edit_calendar_rounded,
  //                                 color: Colors.grey.shade600),
  //                             SizedBox(width: 5),
  //                             Text(
  //                                 submittedTime
  //                                     ? DateTime.now()
  //                                                 .difference(departureTime)
  //                                                 .inDays <
  //                                             -6
  //                                         ? "${departureTime.day}/${departureTime.month} - ${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().length == 1 ? "0${departureTime.minute}" : departureTime.minute} ${departureTime.hour > 12 ? "PM" : "AM"}"
  //                                         : "${(departureTime.weekday == 1) ? "Mon" : (departureTime.weekday == 2) ? "Tue" : (departureTime.weekday == 3) ? "Wed" : (departureTime.weekday == 4) ? "Thu" : (departureTime.weekday == 5) ? "Fri" : (departureTime.weekday == 6) ? "Sat" : "Sun"} - ${departureTime.hour > 12 ? departureTime.hour - 12 : departureTime.hour}:${departureTime.minute.toString().length == 1 ? "0${departureTime.minute}" : departureTime.minute} ${departureTime.hour > 12 ? "PM" : "AM"}"
  //                                     : "Now",
  //                                 style: TextStyle(
  //                                     color: Colors.grey.shade600,
  //                                     height: 1.2,
  //                                     // fontWeight: FontWeight.bold,
  //                                     fontSize: 14))
  //                           ]),
  //                           onPressed: () {
  //                             BottomPicker.dateTime(
  //                                     dismissable: true,
  //                                     initialDateTime:
  //                                         submittedTime ? departureTime : null,
  //                                     onSubmit: ((p0) {
  //                                       setState(() {
  //                                         departureTime = p0;
  //                                         submittedTime = true;
  //                                       });
  //                                     }),
  //                                     onClose: () {
  //                                       setState(() {
  //                                         submittedTime = false;
  //                                       });
  //                                     },
  //                                     title: "Choose departure time",
  //                                     minDateTime: DateTime.now())
  //                                 .show(context);
  //                           },
  //                           padding:
  //                               const EdgeInsets.symmetric(horizontal: 10)),
  //                       ToggleButtons(
  //                           borderColor: Colors.blue,
  //                           fillColor: Colors.green,
  //                           borderWidth: 5,
  //                           color: Colors.blue,
  //                           borderRadius: BorderRadius.circular(15),
  //                           selectedColor: Colors.blue,
  //                           selectedBorderColor: Colors.blue,
  //                           isSelected: const [true, true],
  //                           children: const [Icon(Icons.abc), Text("Goodbye")]),
  //                       ActionChip(
  //                           backgroundColor: Colors.grey.shade200,
  //                           shadowColor: Colors.transparent,
  //                           label: Row(children: [
  //                             Icon(Icons.person, color: Colors.grey.shade600),
  //                             SizedBox(width: 5),
  //                             Text("1",
  //                                 style: TextStyle(
  //                                     color: Colors.grey.shade600,
  //                                     height: 1.2,
  //                                     // fontWeight: FontWeight.bold,
  //                                     fontSize: 14))
  //                           ]),
  //                           onPressed: () {
  //                             BottomPicker(
  //                                     items: [
  //                                   Text(
  //                                     "1",
  //                                     style: TextStyle(height: 2),
  //                                   ),
  //                                   Text(
  //                                     "2",
  //                                     style: TextStyle(height: 2),
  //                                   ),
  //                                   Text(
  //                                     "3",
  //                                     style: TextStyle(height: 2),
  //                                   )
  //                                 ],
  //                                     title: "How many passengers?",
  //                                     dismissable: true)
  //                                 .show(context);
  //                           },
  //                           padding: EdgeInsets.symmetric(horizontal: 15))
  //                     ]))
  //               ]))));
  // }
}

class rideResult extends StatefulWidget {
  const rideResult({Key? key, this.data, required this.scrollController})
      : super(key: key);

  final ScrollController scrollController;
  final data;

  @override
  State<rideResult> createState() => _rideResultState();
}

class _rideResultState extends State<rideResult> {
  var pfpRef = FirebaseStorage.instance
      .refFromURL("gs://hopper-2.appspot.com/kaney.jpeg");

  late Future<Uint8List?> pfp;

  Widget displayRating(String rating) {
    switch (rating) {
      case "0":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "0.5":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star_half),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "1":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "1.5":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star_half),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "2":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "2.5":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star_half),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "3":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star_outline),
          Icon(Icons.star_outline)
        ]);
      case "3.5":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star_half),
          Icon(Icons.star_outline)
        ]);
      case "4":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star_outline)
        ]);
      case "4.5":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star_half)
        ]);
      case "5":
        return Row(mainAxisAlignment: MainAxisAlignment.start, children: const [
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star),
          Icon(Icons.star)
        ]);
    }
    return const SizedBox.shrink();
  }

  Future<Uint8List> getpfp() async {
    widget.scrollController.notifyListeners();
    const oneMegabyte = 1024 * 1024;
    return await pfpRef.getData(oneMegabyte) as Uint8List;
  }

  @override
  void initState() {
    super.initState();
    pfp = getpfp();
  }

  void selectedRide() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => rideDetails(data: widget.data)));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    var rideCost = double.parse((widget.data['payment']['driverCost'] +
                widget.data['payment']['serviceFee'])
            .toString())
        .toStringAsFixed(2);

    return FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Uint8List imageData = snapshot.data as Uint8List;
            if (snapshot.hasData) {
              return Padding(
                  //padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Colors.transparent)),
                      onPressed: selectedRide,
                      child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: Colors.blue,
                                        backgroundImage:
                                            Image.memory(imageData).image)),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: Text(
                                              "${widget.data['driver']['displayInfo']['firstName']} ${widget.data['driver']['displayInfo']['lastName']}")),
                                      displayRating(widget.data['driver']
                                              ['driverInfo']['rating']
                                          .toString())
                                    ]),
                                const VerticalDivider(),
                                Text("\$$rideCost",
                                    style: themeData.textTheme.headline3)
                              ]))));
            }
          }

          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: Colors.transparent)),
                  onPressed: selectedRide,
                  child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: CircleAvatar(radius: 30)),
                            Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(left: 2),
                                      child: Text(
                                          "${widget.data['driver']['displayInfo']['firstName']} ${widget.data['driver']['displayInfo']['lastName']}")),
                                  displayRating(widget.data['driver']
                                          ['driverInfo']['rating']
                                      .toString())
                                ]),
                            const VerticalDivider(),
                            Text("\$$rideCost",
                                style: themeData.textTheme.headline3)
                          ]))));
        }),
        future: pfp);
  }
}

class enrolledRide extends StatefulWidget {
  const enrolledRide({Key? key, this.index, this.data}) : super(key: key);
  final index;
  final data;

  @override
  State<enrolledRide> createState() => _enrolledRideState();
}

class _enrolledRideState extends State<enrolledRide> {
  Set<Polyline> polylines = {};

  void onMapCreated(GoogleMapController mapController) {
    if (NIGHTMODE) {
      rootBundle.loadString('assets/nightMapStyle.json').then(
        (String mapStyle) {
          mapController.setMapStyle(mapStyle);
        },
      );
    } else {
      rootBundle.loadString('assets/dayMapStyle.json').then(
        (String mapStyle) {
          mapController.setMapStyle(mapStyle);
        },
      );
    }

    List<LatLng> coords = [];

    bool add = false;

    for (var coord in widget.data['rideData']['coords']) {
      if (widget.data['passengerData']['locations']['pickup']['coord']
                  ['_latitude'] ==
              coord.latitude &&
          widget.data['passengerData']['locations']['pickup']['coord']
                  ['_longitude'] ==
              coord.longitude) {
        add = true;
      } else if (widget.data['passengerData']['locations']['dropoff']['coord']
                  ['_latitude'] ==
              coord.latitude &&
          widget.data['passengerData']['locations']['dropoff']['coord']
                  ['_longitude'] ==
              coord.longitude) {
        add = false;
      }
      if (add) {
        coords.add(LatLng(coord.latitude, coord.longitude));
      }
    }

    double minLat = coords[0].latitude;
    double minLong = coords[0].longitude;
    double maxLat = coords[0].latitude;
    double maxLong = coords[0].longitude;
    for (var coord in coords) {
      if (coord.latitude < minLat) minLat = coord.latitude;
      if (coord.latitude > maxLat) maxLat = coord.latitude;
      if (coord.longitude < minLong) {
        minLong = coord.longitude;
      }
      if (coord.longitude > maxLong) {
        maxLong = coord.longitude;
      }
    }

    mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLong),
          northeast: LatLng(maxLat, maxLong),
        ),
        50,
      ),
    );

    setState(() {
      polylines = {
        Polyline(
          width: 3,
          polylineId: const PolylineId("firster"),
          points: coords,
          color: Colors.blue,
        )
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const SizedBox(width: 10),
      Flexible(
        child: Stack(children: [
          Container(
              //padding: EdgeInsets.all(10),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    blurRadius: 10,
                    color:
                        NIGHTMODE ? Colors.transparent : Colors.grey.shade200,
                    spreadRadius: 5)
              ]),
              height: 180,
              foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(colors: [
                    Colors.white.withAlpha(NIGHTMODE ? 0 : 100),
                    Colors.white.withAlpha(NIGHTMODE ? 0 : 0),
                    Colors.white.withAlpha(NIGHTMODE ? 0 : 100)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    polylines: polylines,
                    onMapCreated: onMapCreated,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomControlsEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(-45.00202331256251, 168.75192027169524),
                      zoom: 11.0,
                    ),
                  ),
                ),
              )),
          Positioned(
              bottom: 25,
              left: 15,
              child: Row(children: [
                Text("Leave at",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: NIGHTMODE ? Colors.white : null)),
                const SizedBox(width: 5),
                Text("·",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: NIGHTMODE ? Colors.white : null)),
                const SizedBox(width: 5),
                Text(
                    "${DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).hour > 12 ? DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).hour - 12 : DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).hour}:${DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).minute.toString().length == 1 ? "0${DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).minute}" : DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).minute} ${DateTime.parse(widget.data['passengerData']['times']['leaveBy'].toString()).hour > 12 ? "PM" : "AM"}",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ])),
          Positioned(
              top: 15,
              left: 15,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const CircleAvatar(),
                      const SizedBox(width: 10),
                      FutureBuilder(
                          builder: ((context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData) {
                                DocumentSnapshot data =
                                    snapshot.data as DocumentSnapshot;
                                return Text(
                                    "${data['displayInfo']['firstName']} ${data['displayInfo']['lastName']}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            NIGHTMODE ? Colors.white : null));
                              }
                            }
                            return const SizedBox.shrink();
                          }),
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.data['rideData']['driver'])
                              .get()),
                    ]),
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Row(children: [
                          Icon(
                            Icons.pin_drop,
                            color: NIGHTMODE
                                ? Colors.white.withAlpha(180)
                                : Colors.grey.shade700,
                          ),
                          Text(
                              widget.data['passengerData']['locations']
                                  ['destination'],
                              style: TextStyle(
                                  height: 1,
                                  fontSize: 15,
                                  color: NIGHTMODE ? Colors.white : null))
                        ]))
                  ]))
        ]),
      ),
      const SizedBox(width: 10),
    ]);
  }
}

// class _enrolledRideState extends State<enrolledRide> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<DocumentSnapshot>(
//         builder: ((context, snapshot) {
//           //Plan is to let it just be a card with a circular processing icon while it loads, then load data with a cool animation or something

//           var firstName;
//           var lastName;
//           DateTime leaveBy;
//           DateTime arriveBy;
//           var vehicle;
//           var vehiclePlate;
//           double paidFee;
//           double otherRiders;
//           double reducedFee;

//           double totalCost = 0;

//           late GoogleMapController googleMapController;

//           Set<Polyline> polylines = {};
//           Set<Marker> markers = {};

//           void mapCreated(mapController) {
//             googleMapController = mapController;

//             List<LatLng> coords = [];

//             //Declares coords and stuff
//             for (var coord in widget.data['coords']) {
//               //if geoPoint then it should be working
//               coords.add(LatLng(coord.latitude, coord.longitude));
//             }

//             //displays the shit
//             //find LatLng bounds for polyline display
//             double minLat = coords[0].latitude;
//             double minLong = coords[0].longitude;
//             double maxLat = coords[0].latitude;
//             double maxLong = coords[0].longitude;
//             for (var coord in coords) {
//               if (coord.latitude < minLat) minLat = coord.latitude;
//               if (coord.latitude > maxLat) maxLat = coord.latitude;
//               if (coord.longitude < minLong) {
//                 minLong = coord.longitude;
//               }
//               if (coord.longitude > maxLong) {
//                 maxLong = coord.longitude;
//               }
//             }
//             mapController.animateCamera(CameraUpdate.newLatLngBounds(
//                 LatLngBounds(
//                     southwest: LatLng(minLat, minLong),
//                     northeast: LatLng(maxLat, maxLong)),
//                 0));
//             // if (mapController != null) {
//             //   googleMapController = mapController;
//             // } else {
//             //   mapController.animateCamera(CameraUpdate.newLatLngBounds(
//             //       LatLngBounds(
//             //           southwest: LatLng(minLat, minLong),
//             //           northeast: LatLng(maxLat, maxLong)),
//             //       50));
//             // }
//           }

//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasData) {
//               for (var passenger in widget.data['passengers']) {
//                 if (passenger['uid'] ==
//                     FirebaseAuth.instance.currentUser?.uid) {
//                   totalCost = passenger['payment']['serviceFee'] +
//                       passenger['payment']['driverFee'];
//                 }
//               }
//               firstName = snapshot.data?.get('displayInfo')['firstName'];
//               lastName = snapshot.data?.get('displayInfo')['lastName'];

//               //Load polylines
//               List<LatLng> coords = [];

//               LatLng pickup = LatLng(0, 0);
//               LatLng dropoff = LatLng(0, 0);
//               bool logCoords = false;

//               for (var element
//                   in (widget.data['passengers'] as List<dynamic>)) {
//                 if (element['uid'] == FirebaseAuth.instance.currentUser?.uid) {
//                   pickup = LatLng(element['pickup']['coord']['_latitude'],
//                       element['pickup']['coord']['_longitude']);
//                   dropoff = LatLng(element['dropoff']['coord']['_latitude'],
//                       element['dropoff']['coord']['_longitude']);
//                 }
//               }

//               //Declares coords and stuff
//               for (var coord in widget.data['coords']) {
//                 //if geoPoint then it should be working
//                 if (coord.latitude == pickup.latitude &&
//                     coord.longitude == pickup.longitude) {
//                   logCoords = true;
//                 } else if (coord.latitude == dropoff.latitude &&
//                     coord.longitude == dropoff.longitude) {
//                   logCoords = false;
//                 } else if (logCoords) {
//                   coords.add(LatLng(coord.latitude, coord.longitude));
//                 }
//               }

//               polylines = {
//                 Polyline(
//                   endCap: Cap.roundCap,
//                   jointType: JointType.round,
//                   patterns: [PatternItem.dash(10), PatternItem.gap(10)],
//                   width: 3,
//                   polylineId: const PolylineId("firster"),
//                   points: coords,
//                   color: Colors.blue,
//                 )
//               };

//               //Add loaded card here
//             }
//           }

//           return Card(
//               elevation: 1,
//               shadowColor: Colors.transparent.withOpacity(0.5),
//               child: Stack(children: [
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                   SizedBox(
//                       height: 200,
//                       child: GoogleMap(
//                           onMapCreated: (controller) => mapCreated(controller),
//                           polylines: polylines,
//                           markers: markers,
//                           myLocationButtonEnabled: false,
//                           rotateGesturesEnabled: false,
//                           scrollGesturesEnabled: false,
//                           zoomControlsEnabled: false,
//                           zoomGesturesEnabled: false,
//                           initialCameraPosition: const CameraPosition(
//                             target:
//                                 LatLng(-45.00202331256251, 168.75192027169524),
//                             zoom: 11.0,
//                           ))),
//                   Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 10),
//                       child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             Flexible(
//                                 child: Padding(
//                                     padding: const EdgeInsets.only(right: 10),
//                                     child: Column(children: [
//                                       Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             CircleAvatar(),
//                                             SizedBox(width: 10),
//                                             Text(
//                                                 "${firstName ?? ""} ${lastName ?? ""}"),
//                                           ]),
//                                       const Divider(),
//                                       Padding(
//                                           padding: const EdgeInsets.symmetric(
//                                               horizontal: 10),
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(children: [
//                                                   Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: [
//                                                         Text("Leave by"),
//                                                         Text("7:30 AM",
//                                                             style: TextStyle(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold)),
//                                                       ]),
//                                                   const SizedBox(width: 10),
//                                                   Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .start,
//                                                       children: const [
//                                                         Text("Arrive by"),
//                                                         Text("8:10 AM",
//                                                             style: TextStyle(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold))
//                                                       ]),
//                                                 ]),
//                                                 const Text("Car"),
//                                                 const Text("Tesla Model Y",
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold)),
//                                                 const Text("XYFE7F",
//                                                     style: TextStyle(
//                                                         fontWeight:
//                                                             FontWeight.bold))
//                                               ]))
//                                     ]))),
//                             Flexible(
//                                 child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.stretch,
//                                     children: [
//                                   Container(
//                                       decoration: BoxDecoration(
//                                           color: Colors.grey.shade50,
//                                           borderRadius:
//                                               BorderRadius.circular(5.0)),
//                                       child: Padding(
//                                           padding: const EdgeInsets.all(10),
//                                           child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       const Text(
//                                                           "Payment details"),
//                                                       IconButton(
//                                                           //padding won't go away
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(0),
//                                                           onPressed: () {},
//                                                           icon: const Icon(
//                                                               Icons.info,
//                                                               color:
//                                                                   Colors.grey))
//                                                     ]),
//                                                 const Divider(),
//                                                 Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: const [
//                                                       Text("Paid fee:"),
//                                                       Text("\$4.18",
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold))
//                                                     ]),
//                                                 Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: const [
//                                                       Text("Other riders:"),
//                                                       Text("-\$1.11",
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold))
//                                                     ]),
//                                                 const Divider(),
//                                                 Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: const [
//                                                       Text("Reduced fee:"),
//                                                       Text("\$3.07",
//                                                           style: TextStyle(
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold))
//                                                     ]),
//                                               ]))),
//                                   OutlinedButton(
//                                       onPressed: () {},
//                                       style: OutlinedButton.styleFrom(
//                                           side: BorderSide.none,
//                                           backgroundColor: Colors.blue),
//                                       child: Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: const [
//                                             Text("Details",
//                                                 style: TextStyle(
//                                                     color: Colors.white)),
//                                             SizedBox(width: 5),
//                                             Icon(Icons.arrow_forward,
//                                                 color: Colors.white, size: 20)
//                                           ]))
//                                 ]))
//                           ])),
//                 ]),
//                 Positioned(
//                     child: Container(
//                         decoration: BoxDecoration(
//                             color: Colors.blue.shade400.withAlpha(150),
//                             borderRadius: const BorderRadius.only(
//                                 bottomRight: Radius.circular(10))),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 10, vertical: 5),
//                         child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: const [
//                               Icon(Icons.timelapse_rounded,
//                                   color: Colors.white),
//                               SizedBox(width: 5),
//                               Text(
//                                 "Leave soon",
//                                 style: TextStyle(color: Colors.white),
//                               )
//                             ])))
//               ]));
//         }),
//         future: FirebaseFirestore.instance
//             .collection('users')
//             .doc('${widget.data['driver']}')
//             .get());
//   }
// }
