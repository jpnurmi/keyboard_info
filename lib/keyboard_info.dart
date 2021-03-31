import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('keyboard_info');

Future<String?> getKeyboardLayout() {
  return _channel.invokeMethod('getKeyboardLayout');
}
