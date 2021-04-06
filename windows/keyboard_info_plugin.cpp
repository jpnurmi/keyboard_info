#include "include/keyboard_info/keyboard_info_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <winnls.h>
#include <winuser.h>

#include <cwchar>
#include <filesystem>
#include <memory>
#include <sstream>
#include <string>

namespace {

class KeyboardInfoPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void KeyboardInfoPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "keyboard_info",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<KeyboardInfoPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

static LCID toLCID(WCHAR *klid) { return std::wcstoul(klid, NULL, 16); }

static std::string toUTF8(const std::wstring &utf16) {
  return std::filesystem::path(utf16).string();
}

static std::string toLocaleName(LCID lcid) {
  WCHAR buffer[LOCALE_NAME_MAX_LENGTH];
  int len = LCIDToLocaleName(lcid, buffer, LOCALE_NAME_MAX_LENGTH, 0);
  return toUTF8(std::wstring(buffer, len));
}

static bool getKeyboardInfo(std::string &layout, std::string &variant) {
  WCHAR klid[KL_NAMELENGTH];
  if (!GetKeyboardLayoutName(klid)) {
    return false;
  }

  LCID lcid = toLCID(klid);
  layout = toLocaleName(LOWORD(lcid));
  /// ### TODO: variant
  return true;
}

void KeyboardInfoPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getKeyboardInfo") == 0) {
    std::string layout, variant;
    if (getKeyboardInfo(layout, variant)) {
      flutter::EncodableMap info{
        {flutter::EncodableValue("layout"), flutter::EncodableValue(layout)},
        {flutter::EncodableValue("variant"), flutter::EncodableValue(variant)},
      };
      result->Success(flutter::EncodableValue(info));
    } else {
      result->Error(std::to_string(GetLastError()), "GetKeyboardLayoutName");
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void KeyboardInfoPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  KeyboardInfoPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
