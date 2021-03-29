
import 'dart:async';

import 'package:flutter/services.dart';

class KeyboardLayout {
  static const MethodChannel _channel =
      const MethodChannel('keyboard_layout');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
