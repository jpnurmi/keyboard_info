import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:keyboard_layout/keyboard_layout.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _keyboardLayout = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String keyboardLayout;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      keyboardLayout = await getKeyboardLayout();
    } on PlatformException {
      keyboardLayout = 'Failed to get keyboard layout.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _keyboardLayout = keyboardLayout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Keyboard layout example'),
        ),
        body: Center(
          child: Text('Keyboard layout: $_keyboardLayout\n'),
        ),
      ),
    );
  }
}
