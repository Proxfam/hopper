import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:hopper_flutter_app/utils/contants.dart';

class BorderBox extends StatelessWidget {
  const BorderBox(
      {Key? key,
      required this.child,
      required this.padding,
      required this.width,
      required this.height,
      required this.callback})
      : super(key: key);

  final Widget child;
  final EdgeInsets padding;
  final double width, height;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: COLOR_WHITE,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: COLOR_GREY.withAlpha(40), width: 2)),
        child: TextButton(onPressed: callback, child: Container(child: child)));
  }
}
