package com.example.keyboard_info

import androidx.annotation.NonNull

import android.app.Activity
import android.view.inputmethod.InputMethodInfo
import android.view.inputmethod.InputMethodManager
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.Locale

class KeyboardInfoPlugin: FlutterPlugin, ActivityAware, MethodCallHandler {
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "keyboard_info")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
    activity = null
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getKeyboardLayout") {
      result.success(getKeyboardLayout())
    } else {
      result.notImplemented()
    }
  }

  private fun getKeyboardLayout(): String {
    val manager = activity?.getSystemService(Activity.INPUT_METHOD_SERVICE) as? InputMethodManager
    val type = manager?.getCurrentInputMethodSubtype()
    val lang = type?.getLanguageTag()
    if (lang?.isNullOrEmpty() ?: true) {
      val locale = Locale.getDefault()
      var country = locale.getCountry()
      if (country.isNullOrEmpty())
        return locale.getLanguage()
      return country
    }
    return lang ?: ""
  }
}
