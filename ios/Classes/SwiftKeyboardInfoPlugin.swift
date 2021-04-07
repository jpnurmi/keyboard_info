import Flutter
import UIKit

public class SwiftKeyboardInfoPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "keyboard_info", binaryMessenger: registrar.messenger())
    let instance = SwiftKeyboardInfoPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let inputModes = UITextInputMode.activeInputModes
    result([
      "layout": inputModes.first?.primaryLanguage
    ])
  }
}
