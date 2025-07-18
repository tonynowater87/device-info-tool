package com.tonynowater.mobileosversions.mobile_os_versions

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.Context.ACTIVITY_SERVICE
import android.text.format.Formatter
import android.util.DisplayMetrics
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException
import java.util.regex.Pattern
import kotlin.math.roundToInt
import kotlin.math.sqrt

class DeviceInfoHandler(private val activity: Activity) {
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        val displayMetrics = DisplayMetrics()
        activity.windowManager.defaultDisplay.getMetrics(displayMetrics)
        val widthPx = displayMetrics.widthPixels
        val heightPx = displayMetrics.heightPixels
        val density = displayMetrics.density
        val dpInWidth = widthPx / density
        val dpInHeight = heightPx / density
        val widthInches = widthPx / displayMetrics.xdpi
        val heightInches = heightPx / displayMetrics.ydpi
        val inches = sqrt((widthInches * widthInches + heightInches * heightInches).toDouble())

        val cpuInfo = getCpuInfo()

        val map = mapOf(
            "deviceModel" to android.os.Build.MODEL,
            "screenResolutionWidth" to "$widthPx",
            "screenResolutionHeight" to "$heightPx",
            "screenDpSize" to "${dpInWidth.toInt()}x${dpInHeight.toInt()}",
            "screenInch" to String.format("%.1f", inches),
            "androidVersion" to android.os.Build.VERSION.RELEASE,
            "androidSDKInt" to android.os.Build.VERSION.SDK_INT.toString(),
            "securityPatch" to android.os.Build.VERSION.SECURITY_PATCH,
            "deviceBrand" to android.os.Build.MANUFACTURER,
            "ydpi" to displayMetrics.ydpi.toInt().toString(),
            "xdpi" to displayMetrics.xdpi.toInt().toString(),
        )
        result.success(map)
    }


    // https://github.com/jaredrummler/AndroidDeviceNames?tab=readme-ov-file
    private fun getCpuInfo(): Map<String, String> {
        val cpuInfo = mutableMapOf<String, String>()
        try {

            val cpuCoreCount = getPhysicalCpuCores()
            cpuInfo["CPU Core Count"] = cpuCoreCount.toString()

            // get memory info
            val memoryInfo = getMemoryInfo()
            cpuInfo["Total Memory"] = memoryInfo["totalMemory"] ?: "N/A"
            cpuInfo["Available Memory"] = memoryInfo["availableMemory"] ?: "N/A"

            val reader = BufferedReader(FileReader("/proc/cpuinfo"))
            var line: String?
            while (reader.readLine().also { line = it } != null) {
                val parts = line?.split(Pattern.compile(":"), 2)
                if (parts != null && parts.size == 2) {
                    val key = parts[0].trim()
                    val value = parts[1].trim()
                    cpuInfo[key] = value
                }
            }
            reader.close()
        } catch (e: IOException) {
            e.printStackTrace()
        }
        cpuInfo["Hardware"] ?: "N/A"

        return cpuInfo
    }

    private fun getMemoryInfo(): Map<String, String> {

        val activityManager =
            getSystemService(activity, ActivityManager::class.java)
                ?: throw IllegalStateException("ActivityManager not available")
        val memoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)

        // 總記憶體 (API 16+)
        val totalMemory = memoryInfo.totalMem // 單位是 bytes

        // 當前可用記憶體
        val availableMemory = memoryInfo.availMem // 單位是 bytes

        // 系統是否處於低記憶體狀態
        val isLowMemory = memoryInfo.lowMemory

        // 將 bytes 轉換為人類可讀的格式 (e.g., "11.16 GB")
        val totalMemoryStr = Formatter.formatFileSize(activity.applicationContext, totalMemory)
        val availableMemoryStr =
            Formatter.formatFileSize(activity.applicationContext, availableMemory)

        return mapOf(
            "totalMemory" to totalMemoryStr,
            "availableMemory" to availableMemoryStr,
        )
    }


    fun getPhysicalCpuCores(): Int {
        try {
            val cpuPresentFile = File("/sys/devices/system/cpu/present")
            val content = cpuPresentFile.readText() // e.g., "0-7"
            val parts = content.split("-")
            if (parts.size == 2) {
                val start = parts[0].toInt()
                val end = parts[1].toInt()
                return end - start + 1
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
        // 如果失敗，回退到 Runtime API
        return Runtime.getRuntime().availableProcessors()
    }
}