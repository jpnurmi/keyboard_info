#import "KeyboardInfoPlugin.h"
#if __has_include(<keyboard_info/keyboard_info-Swift.h>)
#import <keyboard_info/keyboard_info-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "keyboard_info-Swift.h"
#endif

@implementation KeyboardInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftKeyboardInfoPlugin registerWithRegistrar:registrar];
}
@end
