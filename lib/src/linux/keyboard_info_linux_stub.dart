import 'package:keyboard_info/src/keyboard_info.dart';
import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';

// ignore_for_file: public_member_api_docs

class KeyboardInfoLinux extends KeyboardInfoPlatformInterface {
  @override
  Future<KeyboardInfo> getKeyboardInfo() =>
      Future.value(const KeyboardInfo(layout: ''));
}
