import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:keyboard_info/src/keyboard_info_method_channel.dart';

// ignore_for_file: public_member_api_docs

abstract class KeyboardInfoPlatformInterface extends PlatformInterface {
  KeyboardInfoPlatformInterface() : super(token: _token);

  static final Object _token = Object();
  static KeyboardInfoPlatformInterface _instance = KeyboardInfoMethodChannel();

  static KeyboardInfoPlatformInterface get instance => _instance;
  static set instance(KeyboardInfoPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getKeyboardLayout() {
    throw UnimplementedError('getKeyboardLayout() has not been implemented.');
  }
}
