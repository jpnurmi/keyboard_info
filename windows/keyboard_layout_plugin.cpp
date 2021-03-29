#include "include/keyboard_layout/keyboard_layout_plugin.h"

#include <windows.h>
#include <winnls.h>
#include <winuser.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <cwchar>
#include <filesystem>
#include <memory>
#include <string>
#include <sstream>

namespace {

class KeyboardLayoutPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

 private:
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

void KeyboardLayoutPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "keyboard_layout",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<KeyboardLayoutPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

static LCID toLCID(WCHAR *klid)
{
  return std::wcstoul(klid, NULL, 16);
}

static std::wstring toLocaleName(LCID lcid)
{
  WCHAR buffer[LOCALE_NAME_MAX_LENGTH];
  int len = LCIDToLocaleName(lcid, buffer, LOCALE_NAME_MAX_LENGTH, 0);
  return std::wstring(buffer, len);
}

static std::string toUTF8(const std::wstring &utf16)
{
  return std::filesystem::path(utf16).string();
}

static bool getKeyboardLayoutName(std::string &out)
{
  WCHAR klid[KL_NAMELENGTH];
  if (!GetKeyboardLayoutName(klid)) {
    return false;
  }

  LCID lcid = toLCID(klid);
  std::wstring name = toLocaleName(lcid);
  out = toUTF8(name);
  return true;
}

void KeyboardLayoutPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getKeyboardLayout") == 0) {
    std::string layout;
    if (getKeyboardLayoutName(layout)) {
      result->Success(flutter::EncodableValue(layout));
    } else {
      result->Error(std::to_string(GetLastError()), "GetKeyboardLayoutName");
    }
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void KeyboardLayoutPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  KeyboardLayoutPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
