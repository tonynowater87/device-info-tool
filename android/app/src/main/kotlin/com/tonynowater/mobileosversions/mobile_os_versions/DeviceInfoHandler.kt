package com.tonynowater.mobileosversions.mobile_os_versions // 請替換成你的 package name

import android.content.Context
import android.os.Build
import io.flutter.plugin.common.MethodChannel

// 專門處理裝置資訊的類別
class DeviceInfoHandler(private val context: Context) {

    fun handle(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDeviceInfo" -> getDeviceInfo(result)
            // 如果 DeviceInfoHandler 還要處理其他方法，可以加在這裡
            // "getDeviceName" -> getDeviceName(result) 
            else -> result.notImplemented()
        }
    }

    private fun getDeviceInfo(result: MethodChannel.Result) {
        val deviceInfo = "製造商: ${Build.MANUFACTURER}, 型號: ${Build.MODEL}"
        result.success(deviceInfo)
    }
}