import 'package:dbus/src/dbus_value.dart';
import 'package:file/memory.dart';
import 'package:gsettings/gsettings.dart';
import 'package:keyboard_info/src/keyboard_info_linux.dart';
import 'package:flutter_test/flutter_test.dart';
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
          'mru-sources': DBusArray(DBusSignature('(ss)'), [
            DBusStruct(const [DBusString('xkb'), DBusString('fi+mac')]),
            DBusStruct(const [DBusString('xkb'), DBusString('ru')]),
          ]),
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
          'mru-sources': DBusArray(DBusSignature('(ss)'), []),
          'current': DBusUint32(1),
          'sources': DBusArray(DBusSignature('(ss)'), [
            DBusStruct(const [DBusString('xkb'), DBusString('ua')]),
            DBusStruct(const [DBusString('xkb'), DBusString('fr+oss')]),
          ]),
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
        'layouts': DBusArray.string(['fi\tmac', 'se\twinkeys']),
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
        'layouts': DBusArray.string(['fi\tmac', 'se\twinkeys']),
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
      settings: FakeSettings({
        'mru-sources': DBusArray(DBusSignature('(ss)'), []),
        'current': DBusUint32(0),
        'sources': DBusArray(DBusSignature('(ss)'), []),
      }),
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

class FakeSettings implements GSettings {
  final Map<String, DBusValue> _values;
  FakeSettings(Map<String, DBusValue> values) : _values = values;

  @override
  Future<void> close() async {}

  @override
  Future<DBusValue> get(String name) async => _values[name]!;

  @override
  Stream<List<String>> get keysChanged => throw UnimplementedError();

  @override
  Future<List<String>> list() => throw UnimplementedError();

  @override
  String get schemaName => throw UnimplementedError();

  @override
  Future<void> set(String name, DBusValue values) => throw UnimplementedError();

  @override
  Future<DBusValue> getDefault(String name) => throw UnimplementedError();

  @override
  Future<bool> isSet(String name) => throw UnimplementedError();

  @override
  Future<void> setAll(Map<String, DBusValue?> values) =>
      throw UnimplementedError();

  @override
  Future<void> unset(String name) => throw UnimplementedError();
}
