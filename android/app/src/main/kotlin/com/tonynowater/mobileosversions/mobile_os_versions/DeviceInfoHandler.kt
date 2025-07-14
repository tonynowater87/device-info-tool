package com.tonynowater.mobileosversions.mobile_os_versions

import android.app.Activity
import android.util.DisplayMetrics
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class DeviceInfoHandler(private val activity: Activity) {
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        val displayMetrics = DisplayMetrics()
        activity.windowManager.defaultDisplay.getMetrics(displayMetrics)
        val widthPx = displayMetrics.widthPixels
        val heightPx = displayMetrics.heightPixels
        val density = displayMetrics.density
        val dpInWidth = widthPx / density
        val dpInHeight = heightPx / density
        val map = mapOf(
            "deviceModel" to android.os.Build.MODEL,
            "screenResolutionWidth" to "$widthPx",
            "screenResolutionHeight" to "$heightPx",
            "screenDpSize" to "${dpInWidth.toInt()}x${dpInHeight.toInt()}",
            "androidVersion" to android.os.Build.VERSION.RELEASE,
            "androidSDKInt" to android.os.Build.VERSION.SDK_INT.toString(),
            "securityPatch" to android.os.Build.VERSION.SECURITY_PATCH,
            "deviceBrand" to android.os.Build.MANUFACTURER,
            "ydpi" to displayMetrics.ydpi.toInt().toString(),
            "xdpi" to displayMetrics.xdpi.toInt().toString()
        )
        result.success(map)
    }
}