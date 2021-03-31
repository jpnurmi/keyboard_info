import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_info/keyboard_info.dart';

void main() {
  const MethodChannel channel = MethodChannel('keyboard_info');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return 'fi';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await getKeyboardLayout(), 'fi');
  });
}
