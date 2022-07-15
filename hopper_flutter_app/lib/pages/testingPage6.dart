import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hopper_flutter_app/custom/stripe.dart';
import 'package:passbase_flutter/passbase_flutter.dart';

class testingPage6 extends StatelessWidget {
  const testingPage6({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    bool payFirstClick = false;

    return Scaffold(
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(children: [
                      Text("John Doe", style: themeData.textTheme.headline3),
                      Row(
                        children: const [
                          Icon(Icons.star),
                          Icon(Icons.star),
                          Icon(Icons.star),
                          Icon(Icons.star),
                          Icon(Icons.star_half)
                        ],
                      )
                    ]))
              ])),
          const Divider(indent: 10, endIndent: 10),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Row(
                                  children: const [
                                    Text("7:30",
                                        style: TextStyle(color: Colors.white)),
                                    VerticalDivider(),
                                    Text("Leave home",
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ))
                          ]),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Row(
                              children: const [
                                Text("7:40",
                                    style: TextStyle(color: Colors.white)),
                                VerticalDivider(),
                                Text("Hop on",
                                    style: TextStyle(color: Colors.white))
                              ],
                            ))
                      ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8.0)),
                                child: Row(
                                  children: const [
                                    Text("8:05",
                                        style: TextStyle(color: Colors.white)),
                                    VerticalDivider(),
                                    Text("Hop off",
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ))
                          ]),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Container(
                            height: 50,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8.0)),
                            child: Row(
                              children: const [
                                Text("8:15",
                                    style: TextStyle(color: Colors.white)),
                                VerticalDivider(),
                                Text("Arrive",
                                    style: TextStyle(color: Colors.white))
                              ],
                            ))
                      ]),
                    ])),
          )),
          const Divider(indent: 10, endIndent: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: const Color.fromARGB(14, 0, 0, 0)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(10, 3, 10, 7),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.white),
                          //add container then rows inside
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Hopper ride",
                                    style: themeData.textTheme.bodyMedium)
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Driver fee",
                                    style: themeData.textTheme.bodyMedium),
                                Text("\$6.24 NZD",
                                    style: themeData.textTheme.bodyMedium)
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Service fee",
                                    style: themeData.textTheme.bodyMedium),
                                Text("\$0.75 NZD",
                                    style: themeData.textTheme.bodyMedium)
                              ],
                            )
                          ])),
                      Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total",
                                        style: themeData.textTheme.headline4),
                                    Text("\$6.99 NZD",
                                        style: themeData.textTheme.headline4)
                                  ]),
                              OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  onPressed: () {
                                    if (payFirstClick) {
                                      return;
                                    }
                                    payFirstClick = true;
                                    initPaymentSheet(context, amount: 699,
                                        success: () {
                                      payFirstClick = false;
                                    }, error: (e) {
                                      payFirstClick = false;
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.lock,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      Padding(
                                          padding: EdgeInsets.only(left: 5),
                                          child: Text("Secure pay",
                                              style: TextStyle(
                                                  color: Colors.white)))
                                    ],
                                  ))
                            ],
                          ))
                    ]),
              ),
            ),
          )
        ])));
  }
}
