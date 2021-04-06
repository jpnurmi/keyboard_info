import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Keyboard information including the layout and variant names.
@immutable
class KeyboardInfo extends Equatable {
  /// Constructs a KeyboardInfo with [layout] and [variant].
  KeyboardInfo({required this.layout, this.variant});

  /// The keyboard layout name.
  final String? layout;

  /// The keyboard layout variant.
  final String? variant;

  /// Returns a JSON representation of the KeyboardInfo instance.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'layout': layout,
      'variant': variant,
    };
  }

  /// Constructs a KeyboardInfo instance from JSON.
  static KeyboardInfo fromJson(Map<String, dynamic> json) {
    return KeyboardInfo(
      layout: json['layout'],
      variant: json['variant'],
    );
  }

  @override
  List<Object?> get props => <Object?>[layout, variant];
}
