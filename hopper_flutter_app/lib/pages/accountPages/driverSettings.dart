import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class driverSettings extends StatefulWidget {
  const driverSettings({Key? key}) : super(key: key);

  @override
  State<driverSettings> createState() => _driverSettingsState();
}

class _driverSettingsState extends State<driverSettings> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Driver settings", style: themeData.textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        shadowColor: Colors.transparent,
      ),
    );
  }
}
