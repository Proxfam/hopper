import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

import '../custom/borderBox.dart';

class landingPage extends StatefulWidget {
  const landingPage({Key? key}) : super(key: key);

  @override
  State<landingPage> createState() => _landingPageState();
}

class _landingPageState extends State<landingPage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
        child: Scaffold(
            body: SizedBox(
                width: size.width,
                height: size.height,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        BorderBox(
                          height: 50,
                          width: 50,
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.menu, color: PRIMARY_COLOR),
                        ),
                        BorderBox(
                            height: 50,
                            width: 50,
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.settings, color: PRIMARY_COLOR))
                      ],
                    )
                  ],
                ))));
  }
}
