import 'dart:async';

import 'package:flutter/services.dart';

const MethodChannel _channel = const MethodChannel('keyboard_layout');

Future<String?> getKeyboardLayout() {
  return _channel.invokeMethod('getKeyboardLayout');
}
