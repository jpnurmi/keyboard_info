import 'package:flutter_test/flutter_test.dart';
import 'package:keyboard_info/keyboard_info.dart';

void main() {
  test('JSON', () async {
    final json = <String, dynamic>{
      'layout': 'fi',
      'variant': 'mac',
    };
    final info = KeyboardInfo.fromJson(json);
    expect(info.toJson(), equals(json));
  });
}
