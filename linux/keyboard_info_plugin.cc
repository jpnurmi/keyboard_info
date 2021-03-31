#include "include/keyboard_info/keyboard_info_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gio/gio.h>
#include <glib.h>

#include "third_party/inih-r53/ini.h"

#define KEYBOARD_LAYOUT_PLUGIN(obj)                                   \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), keyboard_info_plugin_get_type(), \
                              KeyboardInfoPlugin))

struct _KeyboardInfoPlugin {
  GObject parent_instance;
};

G_DEFINE_TYPE(KeyboardInfoPlugin, keyboard_info_plugin, g_object_get_type())

static gboolean is_kde() {
  const gchar* desktop = g_getenv("XDG_CURRENT_DESKTOP");
  if (!desktop) {
    return FALSE;
  }
  g_autofree gchar* uppercase = g_utf8_strup(desktop, -1);
  return desktop && strstr(uppercase, "KDE");
}

static void kde_xml_start_element(GMarkupParseContext* context,
                                  const gchar* element_name,
                                  const gchar** attribute_names,
                                  const gchar** attribute_values,
                                  gpointer user_data, GError** error) {
  if (g_strcmp0(element_name, "item") != 0) {
    return;
  }

  guint i = 0;
  while (attribute_names[i] != NULL) {
    const gchar* name = attribute_names[i];
    if (g_strcmp0(name, "currentLayout") == 0) {
      const gchar** layout = (const gchar**)user_data;
      *layout = g_strdup(attribute_values[i]);
      break;
    }
    ++i;
  }
}

static const gchar* parse_kde_layout_memory(const gchar* filename) {
  g_autofree gchar* text = NULL;
  gsize size = 0;
  GError* error = NULL;
  if (!g_file_get_contents(filename, &text, &size, &error)) {
    g_warning("layout_memory.xml: %s\n", error->message);
    return NULL;
  }

  GMarkupParser parser;
  memset(&parser, 0, sizeof(GMarkupParser));
  parser.start_element = kde_xml_start_element;

  gchar* layout = NULL;
  g_autoptr(GMarkupParseContext) context =
      g_markup_parse_context_new(&parser, GMarkupParseFlags(0), &layout, NULL);

  if (!g_markup_parse_context_parse(context, text, size, &error)) {
    g_warning("layout_memory.xml: %s\n", error->message);
    return NULL;
  }

  if (!g_markup_parse_context_end_parse(context, &error)) {
    g_warning("layout_memory.xml: %s\n", error->message);
    return NULL;
  }

  return layout;
}

static int xkbrc_handler(gchar** user, const gchar* section, const gchar* name,
                         const gchar* value) {
  if (g_strcmp0(section, "Layout") != 0 || g_strcmp0(name, "LayoutList") != 0) {
    return FALSE;
  }

  gchar** tokens = g_strsplit_set(value, ",(", 2);
  *user = g_strdup(tokens[0]);
  g_strfreev(tokens);
  return TRUE;
}

static const gchar* parse_kde_xkbrc(const gchar* filename) {
  const gchar* layout = NULL;
  ini_parse(filename, (ini_handler)xkbrc_handler, &layout);
  return layout;
}

static const gchar* get_kde_input_source() {
  g_autofree const gchar* layout_memory = g_build_filename(
      g_get_user_data_dir(), "kded5/keyboard/session/layout_memory.xml", NULL);
  const gchar* layout = parse_kde_layout_memory(layout_memory);
  if (!layout) {
    g_autofree const gchar* kxkbrc =
        g_build_filename(g_get_user_config_dir(), "kxkbrc", NULL);
    layout = parse_kde_xkbrc(kxkbrc);
  }
  return layout;
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

static const gchar* get_keyboard_info() {
  const gchar* layout = NULL;
  if (is_kde()) {
    layout = get_kde_input_source();
  } else {
    layout = get_gnome_input_source();
  }
  if (!layout) {
    layout = get_xkb_layout();
  }
  return layout;
}

static void keyboard_info_plugin_handle_method_call(KeyboardInfoPlugin* self,
                                                    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getKeyboardLayout") == 0) {
    g_autofree const gchar* layout = get_keyboard_info();
    g_autoptr(FlValue) result = fl_value_new_string(layout);
    response = FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void keyboard_info_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(keyboard_info_plugin_parent_class)->dispose(object);
}

static void keyboard_info_plugin_class_init(KeyboardInfoPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = keyboard_info_plugin_dispose;
}

static void keyboard_info_plugin_init(KeyboardInfoPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  KeyboardInfoPlugin* plugin = KEYBOARD_LAYOUT_PLUGIN(user_data);
  keyboard_info_plugin_handle_method_call(plugin, method_call);
}

void keyboard_info_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  KeyboardInfoPlugin* plugin = KEYBOARD_LAYOUT_PLUGIN(
      g_object_new(keyboard_info_plugin_get_type(), nullptr));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "keyboard_info", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  g_object_unref(plugin);
}
