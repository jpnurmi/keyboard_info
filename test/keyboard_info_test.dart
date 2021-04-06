import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_info/keyboard_info.dart';

void main() {
  const MethodChannel channel = MethodChannel('keyboard_info');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return <String, dynamic>{'layout': 'fi'};
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getkeyboardInfo', () async {
    final info = await getKeyboardInfo();
    expect(info.layout, 'fi');
  });
}
