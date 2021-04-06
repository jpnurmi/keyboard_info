/// Retrieves the system's active keyboard layout etc.
library device_info;

import 'dart:async';

import 'package:keyboard_info/src/keyboard_info.dart';
import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';

export 'package:keyboard_info/src/keyboard_info.dart';

/// Retrieves the system's keyboard information including the current layout and
/// variant names.
Future<KeyboardInfo> getKeyboardInfo() => _platform.getKeyboardInfo();

KeyboardInfoPlatformInterface? __platform;

KeyboardInfoPlatformInterface get _platform {
  return __platform ??= KeyboardInfoPlatformInterface.instance;
}
