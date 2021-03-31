import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';

// ignore_for_file: public_member_api_docs

class KeyboardInfoMethodChannel extends KeyboardInfoPlatformInterface {
  @visibleForTesting
  MethodChannel channel = MethodChannel('keyboard_info');

  @override
  Future<String?> getKeyboardLayout() {
    return channel.invokeMethod<String>('getKeyboardLayout');
  }
}
