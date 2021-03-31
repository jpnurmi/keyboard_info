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
    case "getKeyboardLayout":
      let source = TISCopyCurrentKeyboardInputSource().takeUnretainedValue()
      let value = TISGetInputSourceProperty(source, kTISPropertyInputSourceLanguages)
      if (value != nil) {
        let languages = Unmanaged<AnyObject>.fromOpaque(value!).takeUnretainedValue() as? Array<String>
        result(languages?.first)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}