import 'dart:ffi' as ffi;

import 'package:file/memory.dart';
import 'package:gsettings/gsettings.dart';
import 'package:gsettings/src/bindings.dart' as ffi;
import 'package:keyboard_info/src/linux/keyboard_info_linux_real.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:more/tuple.dart';
import 'package:platform/platform.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

bool get isLinux => const LocalPlatform().isLinux;

void main() {
  group('KDE', () {
    test('layout_memory.xml', () async {
      final testFileSystem = MemoryFileSystem.test();
      final file = testFileSystem.file(
          '${xdg.dataHome.path}/kded5/keyboard/session/layout_memory.xml');
      file.createSync(recursive: true);
      file.writeAsStringSync('''
<!DOCTYPE LayoutMap>
<LayoutMap SwitchMode="Global" version="1.0">
  <item currentLayout="fi(mac)"/>
</LayoutMap>
''');
      final keyboard = KeyboardInfoLinux(
        platform: FakePlatform('KDE'),
        fileSystem: testFileSystem,
      );
      final info = await keyboard.getKeyboardInfo();
      expect(info.layout, equals('fi'));
      expect(info.variant, equals('mac'));
    });

    test('kxkbrc', () async {
      final testFileSystem = MemoryFileSystem.test();
      final file = testFileSystem.file('${xdg.configHome.path}/kxkbrc');
      file.createSync(recursive: true);
      file.writeAsStringSync('''
[Layout]
DisplayNames=,,
LayoutList=no(winkeys),us(alt-intl)
LayoutLoopCount=-1
Model=pc101
ResetOldOptions=false
ShowFlag=false
ShowLabel=true
ShowLayoutIndicator=true
ShowSingle=false
SwitchMode=Desktop
Use=true
''');
      final keyboard = KeyboardInfoLinux(
        platform: FakePlatform('KDE'),
        fileSystem: testFileSystem,
      );
      final info = await keyboard.getKeyboardInfo();
      expect(info.layout, equals('no'));
      expect(info.variant, equals('winkeys'));
    });
  }, skip: !isLinux);

  group('GNOME', () {
    test('mru-sources', () async {
      final keyboard = KeyboardInfoLinux(
        platform: FakePlatform('GNOME'),
        settings: FakeSettings({
          'mru-sources': [
            const Tuple2('xkb', 'fi+mac'),
            const Tuple2('xkb', 'ru'),
          ]
        }),
      );
      final info = await keyboard.getKeyboardInfo();
      expect(info.layout, equals('fi'));
      expect(info.variant, equals('mac'));
    });

    test('sources', () async {
      final keyboard = KeyboardInfoLinux(
        platform: FakePlatform('GNOME'),
        settings: FakeSettings({
          'sources': [
            const Tuple2('xkb', 'ua'),
            const Tuple2('xkb', 'fr+oss'),
          ]
        }),
      );
      final info = await keyboard.getKeyboardInfo();
      expect(info.layout, equals('fr'));
      expect(info.variant, equals('oss'));
    });
  }, skip: !isLinux);

  test('MATE', () async {
    final keyboard = KeyboardInfoLinux(
      platform: FakePlatform('MATE'),
      settings: FakeSettings({
        'layouts': ['fi\tmac', 'se\twinkeys'],
      }),
    );
    final info = await keyboard.getKeyboardInfo();
    expect(info.layout, equals('fi'));
    expect(info.variant, equals('mac'));
  }, skip: !isLinux);

  test('Cinnamon', () async {
    final keyboard = KeyboardInfoLinux(
      platform: FakePlatform('Cinnamon'),
      settings: FakeSettings({
        'layouts': ['fi\tmac', 'se\twinkeys'],
      }),
    );
    final info = await keyboard.getKeyboardInfo();
    expect(info.layout, equals('fi'));
    expect(info.variant, equals('mac'));
  }, skip: !isLinux);

  test('XFCE', () async {
    final testFileSystem = MemoryFileSystem.test();
    final file = testFileSystem.file(
        '${xdg.configHome.path}/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml');
    file.createSync(recursive: true);
    file.writeAsStringSync('''
<?xml version="1.0" encoding="UTF-8"?>
<channel name="keyboard-layout" version="1.0">
  <property name="Default" type="empty">
    <property name="XkbDisable" type="bool" value="false"/>
    <property name="XkbLayout" type="string" value="fi,se"/>
    <property name="XkbVariant" type="string" value="winkeys,mac"/>
  </property>
</channel>
''');
    final keyboard = KeyboardInfoLinux(
      platform: FakePlatform('XFCE'),
      fileSystem: testFileSystem,
    );
    final info = await keyboard.getKeyboardInfo();
    expect(info.layout, equals('fi'));
    expect(info.variant, equals('winkeys'));
  }, skip: !isLinux);

  test('xkblayout', () async {
    final testFileSystem = MemoryFileSystem.test();
    final file = testFileSystem.file('/etc/default/keyboard');
    file.createSync(recursive: true);
    file.writeAsStringSync('''
XKBLAYOUT=fr,us
BACKSPACE=guess
XKBVARIANT=oss,
''');
    final keyboard = KeyboardInfoLinux(
      platform: FakePlatform(),
      settings: FakeSettings(),
      fileSystem: testFileSystem,
    );
    final info = await keyboard.getKeyboardInfo();
    expect(info.layout, equals('fr'));
    expect(info.variant, equals('oss'));
  }, skip: !isLinux);
}

class FakePlatform extends LocalPlatform {
  final String? desktop;
  FakePlatform([this.desktop]);
  @override
  Map<String, String> get environment {
    final env = <String, String>{};
    if (desktop != null) {
      env['XDG_CURRENT_DESKTOP'] = desktop!;
    }
    return env;
  }
}

// ignore: must_be_immutable
// ignore: avoid_implementing_value_types
class FakeSettings implements GSettings {
  final Map<String, List<Object?>>? _values;
  FakeSettings([Map<String, List<Object?>>? values]) : _values = values;

  @override
  int intValue(String key) => 1;
  @override
  List<Object?> arrayValue(String key) => _values?[key] ?? [];

  @override
  Object? value(String key) => throw UnimplementedError();
  @override
  void apply() => throw UnimplementedError();
  @override
  bool boolValue(String key) => throw UnimplementedError();
  @override
  List<int?> byteArrayValue(String key) => throw UnimplementedError();
  @override
  GSettings child(String name) => throw UnimplementedError();
  @override
  List<String> children() => throw UnimplementedError();
  @override
  Object? defaultValue(String key) => throw UnimplementedError();
  @override
  void delay() => throw UnimplementedError();
  @override
  Map<Object, Object?> dictValue(String key) => throw UnimplementedError();
  @override
  void dispose() => throw UnimplementedError();
  @override
  double doubleValue(String key) => throw UnimplementedError();
  @override
  int enumValue(String key) => throw UnimplementedError();
  @override
  int flagsValue(String key) => throw UnimplementedError();
  @override
  bool hasUnapplied() => throw UnimplementedError();
  @override
  bool isWritable(String key) => throw UnimplementedError();
  @override
  Object? maybeValue(String key) => throw UnimplementedError();
  @override
  String get path => throw UnimplementedError();
  @override
  List<Object> get props => throw UnimplementedError();
  @override
  void resetValue(String key) => throw UnimplementedError();
  @override
  void revert() => throw UnimplementedError();
  @override
  String get schemaId => throw UnimplementedError();
  @override
  bool setEnumValue(String key, int value) => throw UnimplementedError();
  @override
  bool setFlagsValue(String key, int value) => throw UnimplementedError();
  @override
  bool setValue(String key, Object value) => throw UnimplementedError();
  @override
  List<String?> stringArrayValue(String key) => throw UnimplementedError();
  @override
  String stringValue(String key) => throw UnimplementedError();
  @override
  bool? get stringify => throw UnimplementedError();
  @override
  void sync() => throw UnimplementedError();
  @override
  ffi.Pointer<ffi.GSettings> toPointer() => throw UnimplementedError();
  @override
  Tuple tupleValue(String key) => throw UnimplementedError();
  @override
  Object? userValue(String key) => throw UnimplementedError();
}
