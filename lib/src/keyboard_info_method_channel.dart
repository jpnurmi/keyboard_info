import 'dart:async';

import 'package:flutter/services.dart';
import 'package:keyboard_info/src/keyboard_info.dart';
import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';
import 'package:meta/meta.dart';

// ignore_for_file: public_member_api_docs

class KeyboardInfoMethodChannel extends KeyboardInfoPlatformInterface {
  @visibleForTesting
  final channel = const MethodChannel('keyboard_info');

  @override
  Future<KeyboardInfo> getKeyboardInfo() {
    final json = channel.invokeMapMethod<String, dynamic>('getKeyboardInfo');
    return json.then((value) => KeyboardInfo.fromJson(value ?? {}));
  }
}
