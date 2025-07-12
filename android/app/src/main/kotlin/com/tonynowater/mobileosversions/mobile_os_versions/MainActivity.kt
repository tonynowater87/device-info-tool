package com.tonynowater.mobileosversions.mobile_os_versions

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.tonynowater.mobileosversions"

    private lateinit var batteryInfoHandler: BatteryInfoHandler
    private lateinit var deviceInfoHandler: DeviceInfoHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        batteryInfoHandler = BatteryInfoHandler(this)
        deviceInfoHandler = DeviceInfoHandler(this)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    batteryInfoHandler.onListen(arguments, events)
                }

                override fun onCancel(arguments: Any?) {
                    batteryInfoHandler.onCancel(arguments)
                }
            })

        // Register the platform channel
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceInfo" -> {
                    deviceInfoHandler.handle(call, result)
                }

                "getBatteryInfo" -> {
                    batteryInfoHandler.handle(call, result)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
