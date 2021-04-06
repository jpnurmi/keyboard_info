import 'dart:async';
import 'dart:io';

import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:gsettings/gsettings.dart';
import 'package:meta/meta.dart';
import 'package:more/more.dart';
import 'package:keyboard_info/src/keyboard_info_platform_interface.dart';
import 'package:platform/platform.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;
import 'package:xml/xml.dart';

// ignore_for_file: public_member_api_docs

class KeyboardInfoLinux extends KeyboardInfoPlatformInterface {
  final Platform _platform;
  final FileSystem _fileSystem;
  final GSettings _settings;

  KeyboardInfoLinux(
      {@visibleForTesting Platform platform = const LocalPlatform(),
      @visibleForTesting FileSystem fileSystem = const LocalFileSystem(),
      @visibleForTesting GSettings? settings})
      : _platform = platform,
        _fileSystem = fileSystem,
        _settings =
            settings ?? GSettings(schemaId: 'org.gnome.desktop.input-sources');

  @override
  Future<String?> getKeyboardLayout() async {
    String? layout;
    if (_detectKde()) {
      layout = await _getKdeKeyboardLayout();
    } else {
      layout = await _getGnomeInputSource();
    }
    if (layout == null) {
      layout = await _getXkbLayout();
    }
    return Future.value(layout);
  }

  bool _detectKde() {
    final desktop = _platform.environment['XDG_CURRENT_DESKTOP'];
    return desktop != null && desktop.toUpperCase().contains('KDE');
  }

  String? _parseCurrentKdeLayout(String xml) {
    final doc = XmlDocument.parse(xml);
    final elements = doc.rootElement.findElements('item');
    for (final element in elements) {
      final layout = element.getAttribute('currentLayout');
      if (layout != null) return layout;
    }
    return null;
  }

  String get _kdeLayoutMemoryXmlPath =>
      '${xdg.dataHome.path}/kded5/keyboard/session/layout_memory.xml';

  Future<String?> _getCurrentKdeLayout() async {
    return _fileSystem
        .file(_kdeLayoutMemoryXmlPath)
        .readAsString()
        .then((xml) => _parseCurrentKdeLayout(xml))
        .catchError((e) => null);
  }

  Future<String?> _getKdeKeyboardLayout() async {
    return _getCurrentKdeLayout()
        .then((layout) async => layout ?? await _getKxkbrcLayout());
  }

  String get _kxkbrcPath => '${xdg.configHome.path}/kxkbrc';

  Future<String?> _getKxkbrcLayout() async {
    final keyValues = await _readKeyValues(_kxkbrcPath) ?? {};
    final layout = keyValues['LayoutList']?.split(',').firstOrNull;
    if (layout == null) return null;
    return RegExp(r'(\w+)\(\w+\)').firstMatch(layout)?.group(1);
  }

  Future<String?> _getXkbLayout() async {
    final keyValues = await _readKeyValues('/etc/default/keyboard') ?? {};
    return keyValues['XKBLAYOUT']?.split(',').firstOrNull;
  }

  Future<Map<String, String?>?> _readKeyValues(String path) {
    return _fileSystem
        .file(path)
        .readAsLines()
        .then((lines) => lines.toKeyValues(), onError: (_) => null);
  }

  String? _getGnomeInputSourceSetting(String key, int index) {
    final sources = _settings.arrayValue(key);
    if (index >= sources.length) return null;
    final tuple = sources[index] as Tuple2<Object?, Object?>;
    return tuple.second as String?;
  }

  Future<String?> _getGnomeInputSource() async {
    final source = _getGnomeInputSourceSetting('mru-sources', 0);
    if (source != null) return source;

    // deprecated fallback
    final current = _settings.intValue('current');
    return _getGnomeInputSourceSetting('sources', current);
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

  String? get firstOrNull => isEmpty ? null : first;
}
