/// Retrieves the system's active keyboard layout etc.
library device_info;

import 'dart:async';

import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';

/// Retrieves the system's active keyboard layout.
Future<String?> getKeyboardLayout() => _platform.getKeyboardLayout();

KeyboardInfoPlatformInterface? __platform;

KeyboardInfoPlatformInterface get _platform {
  return __platform ??= KeyboardInfoPlatformInterface.instance;
}
