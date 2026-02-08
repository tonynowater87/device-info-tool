package com.tonynowater.mobileosversions.mobile_os_versions

import android.content.Context
import android.os.Build
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "com.tonynowater.mobileosversions"

    private lateinit var batteryInfoHandler: BatteryInfoHandler
    private lateinit var deviceInfoHandler: DeviceInfoHandler
    private lateinit var bluetoothAudioHandler: BluetoothAudioHandler

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Enable edge-to-edge display
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }

        batteryInfoHandler = BatteryInfoHandler(this)
        deviceInfoHandler = DeviceInfoHandler(this)
        bluetoothAudioHandler = BluetoothAudioHandler(this)
        bluetoothAudioHandler.init()

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

                "getBluetoothAudioInfo" -> {
                    bluetoothAudioHandler.handle(call, result)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        bluetoothAudioHandler.release()
    }
}
