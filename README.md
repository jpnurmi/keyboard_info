# Keyboard Info

[![pub](https://img.shields.io/pub/v/keyboard_info.svg)](https://pub.dev/packages/keyboard_info)
[![license: BSD](https://img.shields.io/badge/license-BSD-yellow.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
![CI](https://github.com/jpnurmi/keyboard_info/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/jpnurmi/keyboard_info/branch/master/graph/badge.svg)](https://codecov.io/gh/jpnurmi/keyboard_info)

This Flutter plugin provides API for querying information about the system keyboard.

## Usage

```dart
import 'package:keyboard_info/keyboard_info.dart`

final KeyboardInfo info = await getKeyboardInfo();
print(info.layout);
print(info.variant);
```

## Platform Support

| Platform | Layout | Variant | Notes |
|---|---|---|---|
| Android | ✔ | ⨯ | • [`InputMethodManager.getCurrentInputMethodSubtype()`](https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#getCurrentInputMethodSubtype())<br/>• [`InputMethodSubtype.getLanguageTag()`](https://developer.android.com/reference/android/view/inputmethod/InputMethodSubtype#getLanguageTag())
| iOS | ✔ | ⨯ | • [`UITextInputMode.activeInputModes`](https://developer.apple.com/documentation/uikit/uitextinputmode/1614522-activeinputmodes)<br/>• [`UITextInputMode.primaryLanguage`](https://developer.apple.com/documentation/uikit/uitextinputmode/1614535-primarylanguage)
| Linux | ✔ | ✔ |  • Cinnamon: `org.gnome.libgnomekbd.keyboard layouts`<br/>• GNOME:<br/>&nbsp;&nbsp;⁃ `org.gnome.desktop.input-sources mru-sources`<br/>&nbsp;&nbsp;⁃ `org.gnome.desktop.input-sources sources`<br/>• KDE:<br/>&nbsp;&nbsp;⁃ `~/.local/share/kded5/keyboard/session/layout_memory.xml`<br/>&nbsp;&nbsp;⁃ `~/.config/kxkbrc`<br/>• MATE: `org.mate.peripherals-keyboard-xkb.kbd layouts`<br/>• XFCE: `~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml`<br/>• Fallback: `/etc/default/keyboard`
| macOS | ✔ | ✔ | • `TISCopyCurrentKeyboardInputSource()`<br/>• `TISGetInputSourceProperty()`<br/>• `kTISPropertyInputSourceLanguages`<br/>• `kTISPropertyInputSourceID`
| Windows | ✔ | ⨯ | • [`GetKeyboardLayoutName()`](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeyboardlayoutnamew)<br/>• [`LCIDToLocaleName()`](https://docs.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-lcidtolocalename)
