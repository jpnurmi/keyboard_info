# Keyboard Info

[![pub](https://img.shields.io/pub/v/keyboard_info.svg)](https://pub.dev/packages/keyboard_info)
[![license: BSD](https://img.shields.io/badge/license-BSD-yellow.svg)](https://opensource.org/licenses/BSD-3-Clause)
[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)
![CI](https://github.com/jpnurmi/keyboard_info/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/jpnurmi/keyboard_info/branch/master/graph/badge.svg)](https://codecov.io/gh/jpnurmi/keyboard_info)

This Flutter plugin provides API for querying information about the system's keyboard.

## Usage

```dart
import 'package:keyboard_info/keyboard_info.dart';

void main() async {
  final KeyboardInfo info = await getKeyboardInfo();
  print(info.layout); // "fi"
  print(info.variant); // "mac"
}
```

## Platform Support

<table>
  <tr><th>Platform</th><th>Layout</th><th>Variant</th><th>Notes</th></tr>
  <tr>
    <td>Android</td><td>✔</td><td>❌</td>
    <td>
      <ul>
        <li><a href="https://developer.android.com/reference/android/view/inputmethod/InputMethodManager#getCurrentInputMethodSubtype()"><tt>InputMethodManager.getCurrentInputMethodSubtype()</tt></a></li>
        <li><a href="https://developer.android.com/reference/android/view/inputmethod/InputMethodSubtype#getLanguageTag()"><tt>InputMethodSubtype.getLanguageTag()</tt></a></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>iOS</td><td>✔</td><td>❌</td>
    <td>
      <ul>
        <li><a href="https://developer.apple.com/documentation/uikit/uitextinputmode/1614522-activeinputmodes"><tt>UITextInputMode.activeInputModes</tt></a></li>
        <li><a href="https://developer.apple.com/documentation/uikit/uitextinputmode/1614535-primarylanguage"><tt>UITextInputMode.primaryLanguage</tt></a></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Linux</td><td>✔</td><td>✔</td>
    <td>
      <ul>
        <li>Cinnamon:
          <ul><li><tt>org.gnome.libgnomekbd.keyboard layouts</tt></li></ul>
        </li>
        <li>GNOME:
          <ul>
            <li><tt>org.gnome.desktop.input-sources mru-sources</tt></li>
            <li><tt>org.gnome.desktop.input-sources sources</tt></li>
          </ul>
        </li>
        <li>KDE:
          <ul>
            <li><tt>~/.local/share/kded5/keyboard/session/layout_memory.xml<tt></li>
            <li><tt>~/.config/kxkbrc</tt></li>
          </ul>
        </li>
        <li>MATE:
          <ul><li><tt>org.mate.peripherals-keyboard-xkb.kbd layouts</tt></li></ul>
        </li>
        <li>XFCE:
          <ul><li><tt>~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml</tt></li></ul>
        </li>
        <li>Fallback: <tt>/etc/default/keyboard</tt></li>
      </ul>
    </td>
  </tr>
  <tr>
    <td>macOS</td><td>✔</td><td>✔</td>
    <td>
      <ul>
        <li><tt>TISCopyCurrentKeyboardInputSource()</tt></li>
        <li><tt>TISGetInputSourceProperty()</tt></li>
        <ul>
          <li><tt>kTISPropertyInputSourceLanguages</tt></li>
          <li><tt>kTISPropertyInputSourceID</tt></li>
        </ul>
      </ul>
    </td>
  </tr>
  <tr>
    <td>Windows</td><td>✔</td><td>❌</td>
    <td>
      <ul>
        <li><a href="https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-getkeyboardlayoutnamew"><tt>GetKeyboardLayoutName()</tt></a></li>
        <li><a href="https://docs.microsoft.com/en-us/windows/win32/api/winnls/nf-winnls-lcidtolocalename"><tt>LCIDToLocaleName()</tt></a></li>
      </ul>
    </td>
  </tr>
</table>
