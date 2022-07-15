import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' as Math;

import 'package:hopper_flutter_app/custom/stripe.dart';

class rideSearcher extends StatelessWidget {
  rideSearcher(
      {Key? key,
      required this.originController,
      required this.destinationController,
      required this.callback})
      : super(key: key);

  final TextEditingController originController;
  final TextEditingController destinationController;
  final Function() callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(children: [
              TextField(
                  controller: originController,
                  decoration: const InputDecoration(
                      icon: Icon(
                        Icons.my_location_rounded,
                        size: 25,
                      ),
                      labelText: "Origin")),
              TextField(
                  controller: destinationController,
                  decoration: InputDecoration(
                      icon: const Icon(
                        Icons.location_pin,
                        size: 25,
                      ),
                      labelText: "Destination",
                      suffixIcon: IconButton(
                          onPressed: callback,
                          icon: const Icon(Icons.search, size: 25))))
            ])));
  }
}

class rideResult extends StatefulWidget {
  const rideResult({Key? key, required this.data}) : super(key: key);

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
    const oneMegabyte = 1024 * 1024;
    return await pfpRef.getData(oneMegabyte) as Uint8List;
  }

  @override
  void initState() {
    super.initState();
    pfp = getpfp();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    var rideCost = num.parse((((widget.data['riderDistance'] / 100000) *
                widget.data['driver']['literPer100km']) *
            3.1)
        .toStringAsFixed(2));

    return FutureBuilder(
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Uint8List imageData = snapshot.data as Uint8List;
            if (snapshot.hasData) {
              // return Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              //   child: Container(
              //     width: MediaQuery.of(context).size.width - 60,
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              //     decoration: BoxDecoration(
              //         color: Colors.grey.shade200,
              //         borderRadius: BorderRadius.circular(8.0)),
              //     child: Column(children: [
              //       Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Padding(
              //                 padding: const EdgeInsets.only(right: 10),
              //                 child: CircleAvatar(
              //                     radius: 30,
              //                     backgroundColor: Colors.blue,
              //                     backgroundImage:
              //                         Image.memory(imageData).image)),
              //             Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   Padding(
              //                       padding: const EdgeInsets.only(left: 2),
              //                       child: Text(
              //                           "${widget.data['driverDetails']['firstName']} ${widget.data['driverDetails']['lastName']}")),
              //                   displayRating(
              //                       widget.data['driver']['rating'].toString())
              //                 ]),
              //             const VerticalDivider(),
              //             Text("\$${rideCost}",
              //                 style: themeData.textTheme.headline3)
              //           ]),
              //       Divider(),
              //       Text("wefwef")
              //     ]),
              //   ),
              // );

              return Padding(
                  //padding: const EdgeInsets.fromLTRB(30, 20, 0, 20),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: Colors.transparent)),
                      onPressed: () {
                        initPaymentSheet(context,
                            amount: double.parse(rideCost.toString()) * 100,
                            success: () {}, error: (e) {
                          print(e);
                        });
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width - 60,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8.0)),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(left: 2),
                                          child: Text(
                                              "${widget.data['driverDetails']['firstName']} ${widget.data['driverDetails']['lastName']}")),
                                      displayRating(widget.data['driver']
                                              ['rating']
                                          .toString())
                                    ]),
                                const VerticalDivider(),
                                Text("\$$rideCost",
                                    style: themeData.textTheme.headline3)
                              ]))));
            }
          }

          return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: CircleAvatar(radius: 30)),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Text(
                                      "${widget.data['driverDetails']['firstName']} ${widget.data['driverDetails']['lastName']}")),
                              displayRating(
                                  widget.data['driver']['rating'].toString())
                            ]),
                        const VerticalDivider(),
                        Text("\$$rideCost",
                            style: themeData.textTheme.headline3)
                      ])));
        }),
        future: pfp);
  }
}
