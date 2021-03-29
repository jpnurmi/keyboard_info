#include "include/keyboard_layout/keyboard_layout_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>
#include <glib.h>

#include "third_party/inih-r53/ini.h"

#define KEYBOARD_LAYOUT_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), keyboard_layout_plugin_get_type(), \
                              KeyboardLayoutPlugin))

struct _KeyboardLayoutPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(KeyboardLayoutPlugin, keyboard_layout_plugin, g_object_get_type())

static const gchar* getenv_up(const gchar* key) {
  return g_utf8_strup(g_getenv(key), -1);
}

static gboolean use_xkb_layout() {
  const gchar* desktop = getenv_up("XDG_CURRENT_DESKTOP");
  return desktop && (strstr(desktop, "KDE") || strstr(desktop, "QT"));
}

static const gchar* get_input_source_setting(GSettings* settings,
                                             const gchar* key, guint index) {
  g_autoptr(GVariant) sources = g_settings_get_value(settings, key);
  if (index >= g_variant_n_children(sources)) {
    return NULL;
  }

  g_autoptr(GVariant) source = g_variant_get_child_value(sources, index);
  gchar* layout = NULL;
  g_variant_get(source, "(ss)", NULL, &layout, NULL);
  return layout;
}

static const gchar* get_gnome_input_source() {
  g_autoptr(GSettings) settings =
      g_settings_new("org.gnome.desktop.input-sources");

  const gchar* source = get_input_source_setting(settings, "mru-sources", 0);
  if (source) {
    return source;
  }

  // deprecated fallback
  guint current = g_settings_get_uint(settings, "current");
  return get_input_source_setting(settings, "sources", current);
}

static int xkb_layout_handler(gchar** user, const gchar* /*section*/,
                              const gchar* name, const gchar* value) {
  if (g_strcmp0(name, "XKBLAYOUT") != 0) {
    return FALSE;
  }

  gchar** tokens = g_strsplit(value, ",", 2);
  *user = g_strdup(tokens[0]);
  g_strfreev(tokens);
  return TRUE;
}

static const gchar* get_xkb_layout() {
  const gchar* layout = NULL;
  ini_parse("/etc/default/keyboard", (ini_handler)xkb_layout_handler, &layout);
  return layout;
}

static const gchar* get_keyboard_layout() {
  if (!use_xkb_layout()) {
    const gchar* layout = get_gnome_input_source();
    if (layout) {
      return layout;
    }
  }
  return get_xkb_layout();
}

static void keyboard_layout_plugin_handle_method_call(
    KeyboardLayoutPlugin* self, FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getKeyboardLayout") == 0) {
    g_autofree const gchar* layout = get_keyboard_layout();
    g_autoptr(FlValue) result = fl_value_new_string(layout);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void keyboard_layout_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(keyboard_layout_plugin_parent_class)->dispose(object);
}

static void keyboard_layout_plugin_class_init(
    KeyboardLayoutPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = keyboard_layout_plugin_dispose;
}

static void keyboard_layout_plugin_init(KeyboardLayoutPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  KeyboardLayoutPlugin* plugin = KEYBOARD_LAYOUT_PLUGIN(user_data);
  keyboard_layout_plugin_handle_method_call(plugin, method_call);
}

void keyboard_layout_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  KeyboardLayoutPlugin* plugin = KEYBOARD_LAYOUT_PLUGIN(
      g_object_new(keyboard_layout_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "keyboard_layout", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
