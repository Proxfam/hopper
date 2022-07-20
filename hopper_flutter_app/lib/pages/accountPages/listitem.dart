import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class listitem extends StatefulWidget {
  const listitem(
      {Key? key, required this.icon, required this.text, this.callback})
      : super(key: key);

  final Icon icon;
  final String text;
  final callback;

  @override
  State<listitem> createState() => _listitemState();
}

class _listitemState extends State<listitem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: OutlinedButton(
            style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 10))),
            onPressed: widget.callback,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: widget.icon),
                  const SizedBox(height: 50, child: VerticalDivider()),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child:
                              Text(widget.text, textAlign: TextAlign.start))),
                ])));
  }
}
