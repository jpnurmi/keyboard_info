import 'dart:async';
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// A web implementation of the KeyboardLayout plugin.
class KeyboardLayoutWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'keyboard_layout',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = KeyboardLayoutWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getKeyboardLayout':
        return getKeyboardLayout();
        break;
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'keyboard_layout for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  /// Returns a [String] containing the keyboard layout.
  Future<String> getKeyboardLayout() {
    return Future.value("");
  }
}
