package com.tonynowater.mobileosversions.mobile_os_versions

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.os.BatteryManager
import android.os.StatFs
import android.os.Environment
import android.text.format.Formatter
import android.util.DisplayMetrics
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException
import java.util.Locale
import java.util.regex.Pattern
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
        val storageInfo = getStorageInfo()
        val batteryInfo = getBatteryInfo()
        val networkInfo = getNetworkInfo()
        val systemInfo = getSystemInfo()

        val map = mutableMapOf(
            "deviceModel" to android.os.Build.MODEL,
            "screenResolutionWidth" to "$widthPx",
            "screenResolutionHeight" to "$heightPx",
            "screenDpSize" to "${dpInWidth.toInt()}x${dpInHeight.toInt()}",
            "screenInch" to String.format("%.1f", inches),
            "androidVersion" to android.os.Build.VERSION.RELEASE,
            "androidSDKInt" to android.os.Build.VERSION.SDK_INT.toString(),
            "securityPatch" to (android.os.Build.VERSION.SECURITY_PATCH ?: ""),
            "deviceBrand" to android.os.Build.MANUFACTURER,
            "ydpi" to displayMetrics.ydpi.toInt().toString(),
            "xdpi" to displayMetrics.xdpi.toInt().toString(),
        )
        map.putAll(cpuInfo)
        map.putAll(storageInfo)
        map.putAll(batteryInfo)
        map.putAll(networkInfo)
        map.putAll(systemInfo)
        result.success(map)
    }

    private fun getCpuInfo(): Map<String, String> {
        val cpuInfo = mutableMapOf<String, String>()
        try {
            val cpuCoreCount = getPhysicalCpuCores()
            cpuInfo["CPU Core Count"] = cpuCoreCount.toString()

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

        val totalMemory = memoryInfo.totalMem
        val availableMemory = memoryInfo.availMem

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
            val content = cpuPresentFile.readText().trim()
            val parts = content.split("-")
            if (parts.size == 2) {
                val start = parts[0].toInt()
                val end = parts[1].toInt()
                return end - start + 1
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return Runtime.getRuntime().availableProcessors()
    }

    private fun getStorageInfo(): Map<String, String> {
        val storageInfo = mutableMapOf<String, String>()
        
        try {
            val internalStorage = Environment.getDataDirectory()
            val internalStat = StatFs(internalStorage.path)
            val internalTotalBytes = internalStat.blockSizeLong * internalStat.blockCountLong
            val internalAvailableBytes = internalStat.blockSizeLong * internalStat.availableBlocksLong
            
            storageInfo["internalStorageTotal"] = Formatter.formatFileSize(activity, internalTotalBytes)
            storageInfo["internalStorageAvailable"] = Formatter.formatFileSize(activity, internalAvailableBytes)
            storageInfo["internalStorageUsed"] = Formatter.formatFileSize(activity, internalTotalBytes - internalAvailableBytes)
            
            if (Environment.getExternalStorageState() == Environment.MEDIA_MOUNTED) {
                val externalStorage = Environment.getExternalStorageDirectory()
                val externalStat = StatFs(externalStorage.path)
                val externalTotalBytes = externalStat.blockSizeLong * externalStat.blockCountLong
                val externalAvailableBytes = externalStat.blockSizeLong * externalStat.availableBlocksLong
                
                storageInfo["externalStorageTotal"] = Formatter.formatFileSize(activity, externalTotalBytes)
                storageInfo["externalStorageAvailable"] = Formatter.formatFileSize(activity, externalAvailableBytes)
                storageInfo["externalStorageUsed"] = Formatter.formatFileSize(activity, externalTotalBytes - externalAvailableBytes)
            } else {
                storageInfo["externalStorageTotal"] = "Not Available"
                storageInfo["externalStorageAvailable"] = "Not Available"
                storageInfo["externalStorageUsed"] = "Not Available"
            }
        } catch (e: Exception) {
            e.printStackTrace()
            storageInfo["storageError"] = e.message ?: "Unknown storage error"
        }
        
        return storageInfo
    }

    private fun getBatteryInfo(): Map<String, String> {
        val batteryInfo = mutableMapOf<String, String>()
        
        try {
            val batteryManager = activity.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
            
            batteryInfo["batteryLevel"] = "$batteryLevel%"
            
            // Use BroadcastReceiver to get more detailed battery info
            val batteryIntent = activity.registerReceiver(null, android.content.IntentFilter(android.content.Intent.ACTION_BATTERY_CHANGED))
            
            if (batteryIntent != null) {
                val status = batteryIntent.getIntExtra(android.os.BatteryManager.EXTRA_STATUS, -1)
                val health = batteryIntent.getIntExtra(android.os.BatteryManager.EXTRA_HEALTH, -1)
                val technology = batteryIntent.getStringExtra(android.os.BatteryManager.EXTRA_TECHNOLOGY) ?: "Unknown"
                val temperature = batteryIntent.getIntExtra(android.os.BatteryManager.EXTRA_TEMPERATURE, -1) / 10.0f
                val voltage = batteryIntent.getIntExtra(android.os.BatteryManager.EXTRA_VOLTAGE, -1) / 1000.0f
                
                batteryInfo["batteryStatus"] = when (status) {
                    android.os.BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
                    android.os.BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
                    android.os.BatteryManager.BATTERY_STATUS_FULL -> "Full"
                    android.os.BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "Not Charging"
                    else -> "Unknown"
                }
                batteryInfo["batteryHealth"] = when (health) {
                    android.os.BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
                    android.os.BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
                    android.os.BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
                    android.os.BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over Voltage"
                    android.os.BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
                    else -> "Unknown"
                }
                batteryInfo["batteryTechnology"] = technology
                if (temperature > 0) {
                    batteryInfo["batteryTemperature"] = "${temperature}°C"
                }
                if (voltage > 0) {
                    batteryInfo["batteryVoltage"] = "${voltage}V"
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            batteryInfo["batteryError"] = e.message ?: "Unknown battery error"
        }
        
        return batteryInfo
    }

    private fun getNetworkInfo(): Map<String, String> {
        val networkInfo = mutableMapOf<String, String>()
        
        try {
            val connectivityManager = activity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val activeNetwork = connectivityManager.activeNetworkInfo
            
            if (activeNetwork != null && activeNetwork.isConnected) {
                networkInfo["networkType"] = when (activeNetwork.type) {
                    ConnectivityManager.TYPE_WIFI -> "WiFi"
                    ConnectivityManager.TYPE_MOBILE -> "Mobile Data"
                    ConnectivityManager.TYPE_ETHERNET -> "Ethernet"
                    ConnectivityManager.TYPE_BLUETOOTH -> "Bluetooth"
                    else -> "Other"
                }
                networkInfo["networkSubtype"] = activeNetwork.subtypeName
                networkInfo["networkState"] = activeNetwork.state.toString()
                networkInfo["networkIsRoaming"] = activeNetwork.isRoaming.toString()
            } else {
                networkInfo["networkType"] = "Not Connected"
                networkInfo["networkSubtype"] = "N/A"
                networkInfo["networkState"] = "Disconnected"
                networkInfo["networkIsRoaming"] = "N/A"
            }
        } catch (e: Exception) {
            e.printStackTrace()
            networkInfo["networkError"] = e.message ?: "Unknown network error"
        }
        
        return networkInfo
    }

    private fun getSystemInfo(): Map<String, String> {
        val systemInfo = mutableMapOf<String, String>()
        
        try {
            systemInfo["androidId"] = android.provider.Settings.Secure.getString(
                activity.contentResolver,
                android.provider.Settings.Secure.ANDROID_ID
            )
            systemInfo["deviceName"] = android.os.Build.DEVICE
            systemInfo["deviceProduct"] = android.os.Build.PRODUCT
            systemInfo["deviceBoard"] = android.os.Build.BOARD
            systemInfo["deviceHardware"] = android.os.Build.HARDWARE
            systemInfo["deviceBootloader"] = android.os.Build.BOOTLOADER
            systemInfo["deviceFingerprint"] = android.os.Build.FINGERPRINT
            systemInfo["deviceHost"] = android.os.Build.HOST
            systemInfo["deviceUser"] = android.os.Build.USER
            systemInfo["deviceTime"] = android.os.Build.TIME.toString()
            systemInfo["deviceType"] = android.os.Build.TYPE
            systemInfo["deviceTags"] = android.os.Build.TAGS
            systemInfo["deviceRadioVersion"] = android.os.Build.getRadioVersion() ?: "Unknown"
            systemInfo["systemLocale"] = Locale.getDefault().toString()
            systemInfo["systemTimeZone"] = java.util.TimeZone.getDefault().id
            systemInfo["kernelVersion"] = getKernelVersion()
            systemInfo["supportedABIs"] = android.os.Build.SUPPORTED_ABIS.joinToString(", ")
            systemInfo["is64Bit"] = (android.os.Build.SUPPORTED_64_BIT_ABIS.isNotEmpty()).toString()
        } catch (e: Exception) {
            e.printStackTrace()
            systemInfo["systemError"] = e.message ?: "Unknown system error"
        }
        
        return systemInfo
    }

    private fun getKernelVersion(): String {
        return try {
            val versionFile = File("/proc/version")
            if (versionFile.exists()) {
                versionFile.readText().trim()
            } else {
                "Unknown"
            }
        } catch (e: Exception) {
            "Unknown"
        }
    }
}