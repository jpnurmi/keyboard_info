//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <keyboard_layout/keyboard_layout_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) keyboard_layout_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "KeyboardLayoutPlugin");
  keyboard_layout_plugin_register_with_registrar(keyboard_layout_registrar);
}
