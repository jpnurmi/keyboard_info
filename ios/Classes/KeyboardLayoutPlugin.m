#import "KeyboardLayoutPlugin.h"
#if __has_include(<keyboard_layout/keyboard_layout-Swift.h>)
#import <keyboard_layout/keyboard_layout-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "keyboard_layout-Swift.h"
#endif

@implementation KeyboardLayoutPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKeyboardLayoutPlugin registerWithRegistrar:registrar];
}
@end
