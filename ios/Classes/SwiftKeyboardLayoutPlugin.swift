import Flutter
import UIKit

public class SwiftKeyboardLayoutPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "keyboard_layout", binaryMessenger: registrar.messenger())
    let instance = SwiftKeyboardLayoutPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let inputModes = UITextInputMode.activeInputModes
    result(inputModes.first?.primaryLanguage)
  }
}
