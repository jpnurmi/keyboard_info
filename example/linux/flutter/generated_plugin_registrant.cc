//
//  Generated file. Do not edit.
//

#include "generated_plugin_registrant.h"

#include <keyboard_info/keyboard_info_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) keyboard_info_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "KeyboardInfoPlugin");
  keyboard_info_plugin_register_with_registrar(keyboard_info_registrar);
}
