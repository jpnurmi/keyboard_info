import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_info/keyboard_info.dart';
import 'package:keyboard_info/src/keyboard_info_method_channel.dart';
import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';

void main() {
  const MethodChannel channel = MethodChannel('keyboard_info');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    KeyboardInfoPlatformInterface.instance = KeyboardInfoMethodChannel();

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return <String, dynamic>{
        'layout': 'fi',
        'variant': 'mac',
      };
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getkeyboardInfo', () async {
    final info = await getKeyboardInfo();
    expect(info.layout, 'fi');
    expect(info.variant, 'mac');
  });
}
