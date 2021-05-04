import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class KeyboardInfoWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'keyboard_info',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = KeyboardInfoWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getKeyboardInfo':
        return <String, dynamic>{};
      default:
        throw PlatformException(code: 'Unimplemented', details: call.method);
    }
  }
}
