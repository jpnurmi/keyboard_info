import 'dart:async';

import 'package:dbus/dbus.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:gsettings/gsettings.dart';
import 'package:keyboard_info/src/keyboard_info.dart';
import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:xml/xml.dart';

// ignore_for_file: public_member_api_docs

class KeyboardInfoLinux extends KeyboardInfoPlatformInterface {
  final Platform _platform;
  final FileSystem _fileSystem;
  final GSettings? _settings;

  KeyboardInfoLinux(
      {@visibleForTesting Platform platform = const LocalPlatform(),
      @visibleForTesting FileSystem fileSystem = const LocalFileSystem(),
      @visibleForTesting GSettings? settings})
      : _platform = platform,
        _fileSystem = fileSystem,
        _settings = settings;

  @override
  Future<KeyboardInfo> getKeyboardInfo() async {
    KeyboardInfo? info;
    switch (_detectDesktop()) {
      case 'KDE':
        info = await _getKdeKeyboardLayout();
        break;
      case 'XFCE':
        info = await _getXfceKeyboardLayout();
        break;
      case 'MATE':
        info = await _getMateKeyboardLayout();
        break;
      case 'Cinnamon':
        info = await _getCinnamonKeyboardLayout();
        break;
      default:
        info = await _getGnomeInputSource();
    }
    info ??= await _getXkbLayout();
    return Future.value(info);
  }

  String? _detectDesktop() {
    final desktop = _platform.environment['XDG_CURRENT_DESKTOP']?.toUpperCase();
    if (desktop != null) {
      if (desktop.contains('KDE')) return 'KDE';
      if (desktop.contains('MATE')) return 'MATE';
      if (desktop.contains('CINNAMON')) return 'Cinnamon';
      if (desktop.contains('XFCE')) return 'XFCE';
    }
    return null;
  }

  KeyboardInfo? _parseKeyboardInfo(String layout) {
    final match = RegExp(r'(\w+)(?:\((\w+)\))?').firstMatch(layout);
    if (match == null) return null;
    return KeyboardInfo(
      layout: match.group(1),
      variant: match.group(2),
    );
  }

  KeyboardInfo? _parseCurrentKdeLayout(String xml) {
    final doc = XmlDocument.parse(xml);
    final elements = doc.rootElement.findElements('item');
    for (final element in elements) {
      final layout = element.getAttribute('currentLayout');
      if (layout != null) {
        return _parseKeyboardInfo(layout);
      }
    }
    return null;
  }

  String get _kdeLayoutMemoryXmlPath =>
      '${xdg.dataHome.path}/kded5/keyboard/session/layout_memory.xml';

  Future<KeyboardInfo?> _getCurrentKdeLayout() async {
    return _fileSystem
        .file(_kdeLayoutMemoryXmlPath)
        .readAsString()
        .then((xml) => _parseCurrentKdeLayout(xml))
        .catchError((e) => null);
  }

  Future<KeyboardInfo?> _getKdeKeyboardLayout() async {
    return _getCurrentKdeLayout()
        .then((layout) async => layout ?? await _getKxkbrcLayout());
  }

  String get _kxkbrcPath => '${xdg.configHome.path}/kxkbrc';

  Future<KeyboardInfo?> _getKxkbrcLayout() async {
    final keyValues = await _readKeyValues(_kxkbrcPath) ?? {};
    final layout = keyValues['LayoutList']?.split(',').firstOrNull;
    return _parseKeyboardInfo(layout ?? '');
  }

  KeyboardInfo? _parseXfceKeyboardLayout(String xml) {
    final doc = XmlDocument.parse(xml);
    final elements = doc.rootElement.findAllElements('property');
    String? layout;
    String? variant;
    for (final element in elements) {
      final name = element.getAttribute('name');
      if (name == 'XkbLayout') {
        layout ??= element.getAttribute('value');
      } else if (name == 'XkbVariant') {
        variant ??= element.getAttribute('value');
      }
      if (layout != null && variant != null) break;
    }
    if (layout == null) return null;
    return KeyboardInfo(
      layout: layout.split(',').firstOrNull,
      variant: variant?.split(',').firstOrNull,
    );
  }

  String get _xfceConfigXmlPath =>
      '${xdg.configHome.path}/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml';

  Future<KeyboardInfo?> _getXfceKeyboardLayout() async {
    return _fileSystem
        .file(_xfceConfigXmlPath)
        .readAsString()
        .then((xml) => _parseXfceKeyboardLayout(xml))
        .catchError((e) => null);
  }

  Future<KeyboardInfo> _getXkbLayout() async {
    final keyValues = await _readKeyValues('/etc/default/keyboard') ?? {};
    return KeyboardInfo(
      layout: keyValues['XKBLAYOUT']?.split(',').firstOrNull,
      variant: keyValues['XKBVARIANT']?.split(',').firstOrNull,
    );
  }

  Future<Map<String, String?>?> _readKeyValues(String path) {
    return _fileSystem
        .file(path)
        .readAsLines()
        .then((lines) => lines.toKeyValues(), onError: (_) => null);
  }

  GSettings _getSettings(String schemaId) {
    return _settings ?? GSettings(schemaId);
  }

  KeyboardInfo? _splitKeyboardInfo(String? id, String separator) {
    if (id == null) return null;
    final split = id.split(separator);
    return KeyboardInfo(
      layout: split.firstOrNull,
      variant: split.secondOrNull,
    );
  }

  Future<KeyboardInfo?> _getMateKeyboardLayout() async {
    final settings = _getSettings('org.mate.peripherals-keyboard-xkb.kbd');
    final layouts = await settings.get('layouts') as DBusArray;
    final id = layouts.children.firstOrNull as DBusString?;
    return _splitKeyboardInfo(id?.value, '\t');
  }

  Future<KeyboardInfo?> _getCinnamonKeyboardLayout() async {
    final settings = _getSettings('org.gnome.libgnomekbd.keyboard');
    final layouts = await settings.get('layouts') as DBusArray;
    final layout = layouts.children.firstOrNull as DBusString?;
    return _splitKeyboardInfo(layout?.value, '\t');
  }

  Future<KeyboardInfo?> _getGnomeInputSourceSetting(
      String key, int index) async {
    final settings = _getSettings('org.gnome.desktop.input-sources');
    final sources = await settings.get(key) as DBusArray;
    final source = sources.children.valueOrNull(index) as DBusStruct?;
    final id = source?.children.secondOrNull as DBusString?;
    return _splitKeyboardInfo(id?.value, '+');
  }

  Future<KeyboardInfo?> _getGnomeInputSource() async {
    final source = await _getGnomeInputSourceSetting('mru-sources', 0);
    if (source != null) return source;

    // deprecated fallback
    final settings = _getSettings('org.gnome.desktop.input-sources');
    final current = await settings.get('current');
    return _getGnomeInputSourceSetting(
        'sources', (current as DBusUint32).value);
  }
}

extension _StringList on List<String> {
  Map<String, String?> toKeyValues() {
    return Map.fromEntries(map((line) {
      final parts = line.split('=');
      if (parts.length != 2) return MapEntry(line, null);
      return MapEntry(parts.first, parts.last);
    }));
  }
}

extension _ListOrNull<T> on List<T> {
  T? get firstOrNull => valueOrNull(0);
  T? get secondOrNull => valueOrNull(1);
  T? valueOrNull(int index) => index >= length ? null : this[index];
}
