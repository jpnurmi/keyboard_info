import Cocoa
import FlutterMacOS
import InputMethodKit

public class KeyboardInfoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "keyboard_info", binaryMessenger: registrar.messenger)
    let instance = KeyboardInfoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getKeyboardInfo":
      let source = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()

      var layouts:Array<String>?;
      let sourceLang = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages)
      if (sourceLang != nil) {
        layouts = Unmanaged<AnyObject>.fromOpaque(sourceLang!).takeUnretainedValue() as? Array<String>
      }

      var variant:String?;
      let sourceId = TISGetInputSourceProperty(source, kTISPropertyInputSourceID)
      if (sourceId != nil) {
        variant = Unmanaged<AnyObject>.fromOpaque(sourceId!).takeUnretainedValue() as? String
      }

      result([
        "layout": layouts?.first,
        "variant": variant
      ]);
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
