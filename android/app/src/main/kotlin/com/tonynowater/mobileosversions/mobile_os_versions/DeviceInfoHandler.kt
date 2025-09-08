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
import android.os.storage.StorageManager
import android.app.usage.StorageStatsManager
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
            // Method 1: Try StorageStatsManager API for Android 8.0+ (API 26+)
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val storageStatsResult = getStorageInfoUsingStorageStats()
                if (storageStatsResult != null) {
                    storageInfo.putAll(storageStatsResult)
                    return storageInfo
                }
            }
            
            // Method 2: Try multiple paths with different strategies
            val storageResults = tryMultipleStorageMethods()
            if (storageResults != null) {
                storageInfo.putAll(storageResults)
                return storageInfo
            }
            
            // Method 3: Fallback to basic method
            getStorageInfoFallback(storageInfo)
            
        } catch (e: Exception) {
            e.printStackTrace()
            storageInfo["storageError"] = e.message ?: "Unknown storage error"
            setStorageError(storageInfo)
        }
        
        return storageInfo
    }
    
    private fun getStorageInfoUsingStorageStats(): Map<String, String>? {
        try {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                val storageStatsManager = activity.getSystemService(Context.STORAGE_STATS_SERVICE) as StorageStatsManager
                val storageManager = activity.getSystemService(Context.STORAGE_SERVICE) as StorageManager
                
                // Get the primary storage volume
                val primaryVolume = storageManager.primaryStorageVolume
                val uuid = storageManager.getUuidForPath(activity.filesDir)
                
                val totalBytes = storageStatsManager.getTotalBytes(uuid)
                val freeBytes = storageStatsManager.getFreeBytes(uuid)
                val usedBytes = totalBytes - freeBytes
                
                return mapOf(
                    "internalStorageTotal" to Formatter.formatFileSize(activity, totalBytes),
                    "internalStorageAvailable" to Formatter.formatFileSize(activity, freeBytes),
                    "internalStorageUsed" to Formatter.formatFileSize(activity, usedBytes),
                    "externalStorageTotal" to Formatter.formatFileSize(activity, totalBytes),
                    "externalStorageAvailable" to Formatter.formatFileSize(activity, freeBytes),
                    "externalStorageUsed" to Formatter.formatFileSize(activity, usedBytes),
                    "debugStoragePath" to "StorageStatsManager API"
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
    
    private fun tryMultipleStorageMethods(): Map<String, String>? {
        // Try different storage paths and calculation methods
        val methods = listOf(
            { getStorageFromPath("/storage/emulated/0") },
            { getStorageFromPath("/sdcard") },
            { getStorageFromPath("/mnt/sdcard") },
            { getStorageFromEnvironment() },
            { getStorageFromDataDirectory() }
        )
        
        var bestResult: Map<String, String>? = null
        var bestTotal = 0L
        
        for (method in methods) {
            try {
                val result = method()
                if (result != null) {
                    // Try to parse the total to compare
                    val totalStr = result["totalBytes"] as? Long
                    if (totalStr != null && totalStr > bestTotal) {
                        bestTotal = totalStr
                        bestResult = mapOf(
                            "internalStorageTotal" to Formatter.formatFileSize(activity, totalStr),
                            "internalStorageAvailable" to result["availableFormatted"] as String,
                            "internalStorageUsed" to result["usedFormatted"] as String,
                            "externalStorageTotal" to Formatter.formatFileSize(activity, totalStr),
                            "externalStorageAvailable" to result["availableFormatted"] as String,
                            "externalStorageUsed" to result["usedFormatted"] as String,
                            "debugStoragePath" to (result["path"] as String)
                        )
                    }
                }
            } catch (e: Exception) {
                continue
            }
        }
        
        return bestResult
    }
    
    private fun getStorageFromPath(path: String): Map<String, Any>? {
        try {
            val file = File(path)
            if (file.exists()) {
                val stat = StatFs(path)
                val totalBytes = stat.blockSizeLong * stat.blockCountLong
                val availableBytes = stat.blockSizeLong * stat.availableBlocksLong
                val usedBytes = totalBytes - availableBytes
                
                return mapOf(
                    "path" to path,
                    "totalBytes" to totalBytes,
                    "availableFormatted" to Formatter.formatFileSize(activity, availableBytes),
                    "usedFormatted" to Formatter.formatFileSize(activity, usedBytes)
                )
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
    
    private fun getStorageFromEnvironment(): Map<String, Any>? {
        try {
            val extDir = Environment.getExternalStorageDirectory()
            return getStorageFromPath(extDir.absolutePath)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
    
    private fun getStorageFromDataDirectory(): Map<String, Any>? {
        try {
            val dataDir = Environment.getDataDirectory()
            return getStorageFromPath(dataDir.absolutePath)
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
    
    private fun findMainStoragePath(): String? {
        try {
            // Priority order: Try user-accessible storage paths first, avoid system paths
            val userStoragePaths = listOf(
                "/storage/emulated/0",  // Primary user storage
                "/sdcard",              // User accessible sdcard
                "/storage/self/primary", // Alternative user storage
                Environment.getExternalStorageDirectory().absolutePath  // Android API path
            )
            
            // First, try user storage paths
            for (path in userStoragePaths) {
                try {
                    val file = File(path)
                    if (file.exists() && file.canRead()) {
                        val stat = StatFs(path)
                        val totalBytes = stat.blockSizeLong * stat.blockCountLong
                        // If we find a valid user storage path with reasonable size (>10GB), use it
                        if (totalBytes > 10L * 1024 * 1024 * 1024) { // More than 10GB
                            return path
                        }
                    }
                } catch (e: Exception) {
                    continue
                }
            }
            
            // If no good user storage found, read /proc/mounts but exclude /data
            val mountsFile = File("/proc/mounts")
            if (mountsFile.exists()) {
                val reader = BufferedReader(FileReader(mountsFile))
                var line: String?
                while (reader.readLine().also { line = it } != null) {
                    val parts = line!!.split(" ")
                    if (parts.size >= 2) {
                        val mountPoint = parts[1]
                        // Look for user-accessible storage mount points, skip system ones
                        when {
                            mountPoint == "/storage/emulated/0" -> {
                                reader.close()
                                return "/storage/emulated/0"
                            }
                            mountPoint.contains("/storage/emulated") -> {
                                reader.close()
                                return mountPoint
                            }
                            mountPoint == "/sdcard" -> {
                                reader.close()
                                return "/sdcard"
                            }
                            // Skip /data as it's system storage, not user storage
                        }
                    }
                }
                reader.close()
            }
            
            // Last resort: try to find largest non-system storage
            val fallbackPaths = listOf(
                "/storage/emulated/0", 
                "/sdcard",
                "/mnt/sdcard",
                Environment.getExternalStorageDirectory().absolutePath
            )
            
            var bestPath: String? = null
            var bestSize = 0L
            
            for (path in fallbackPaths) {
                try {
                    val file = File(path)
                    if (file.exists()) {
                        val stat = StatFs(path)
                        val totalBytes = stat.blockSizeLong * stat.blockCountLong
                        if (totalBytes > bestSize) {
                            bestSize = totalBytes
                            bestPath = path
                        }
                    }
                } catch (e: Exception) {
                    continue
                }
            }
            
            return bestPath
            
        } catch (e: Exception) {
            e.printStackTrace()
            return null
        }
    }
    
    private fun getStorageInfoFallback(storageInfo: MutableMap<String, String>) {
        try {
            // Try different paths to get the most accurate storage information
            val paths = listOf(
                "/storage/emulated/0",  // Primary external storage
                Environment.getExternalStorageDirectory().absolutePath,  // External storage
                Environment.getDataDirectory().absolutePath,  // Data directory
                activity.filesDir.absolutePath  // App files directory
            )
            
            var bestStat: StatFs? = null
            var bestTotalBytes = 0L
            
            for (path in paths) {
                try {
                    val stat = StatFs(path)
                    val totalBytes = stat.blockSizeLong * stat.blockCountLong
                    if (totalBytes > bestTotalBytes) {
                        bestTotalBytes = totalBytes
                        bestStat = stat
                    }
                } catch (e: Exception) {
                    // Continue to next path
                    continue
                }
            }
            
            if (bestStat != null) {
                val totalBytes = bestStat.blockSizeLong * bestStat.blockCountLong
                val availableBytes = bestStat.blockSizeLong * bestStat.availableBlocksLong
                val usedBytes = totalBytes - availableBytes
                
                storageInfo["internalStorageTotal"] = Formatter.formatFileSize(activity, totalBytes)
                storageInfo["internalStorageAvailable"] = Formatter.formatFileSize(activity, availableBytes)
                storageInfo["internalStorageUsed"] = Formatter.formatFileSize(activity, usedBytes)
            } else {
                setStorageError(storageInfo)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            setStorageError(storageInfo)
        }
    }
    
    private fun setStorageError(storageInfo: MutableMap<String, String>) {
        storageInfo["internalStorageTotal"] = "Error"
        storageInfo["internalStorageAvailable"] = "Error"
        storageInfo["internalStorageUsed"] = "Error"
        storageInfo["externalStorageTotal"] = "Error"
        storageInfo["externalStorageAvailable"] = "Error"
        storageInfo["externalStorageUsed"] = "Error"
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
            systemInfo["isDeveloperOptionsEnabled"] = isDeveloperOptionsEnabled().toString()
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

    private fun isDeveloperOptionsEnabled(): Boolean {
        return try {
            // Try multiple methods to detect developer options
            
            // Method 1: Check DEVELOPMENT_SETTINGS_ENABLED
            var isEnabled = false
            try {
                val developerOptionsEnabled = android.provider.Settings.Global.getInt(
                    activity.contentResolver,
                    android.provider.Settings.Global.DEVELOPMENT_SETTINGS_ENABLED,
                    0
                )
                isEnabled = developerOptionsEnabled == 1
            } catch (e: Exception) {
                // Method 1 failed, try method 2
            }
            
            // Method 2: Check ADB_ENABLED (USB debugging)
            if (!isEnabled) {
                try {
                    val adbEnabled = android.provider.Settings.Global.getInt(
                        activity.contentResolver,
                        android.provider.Settings.Global.ADB_ENABLED,
                        0
                    )
                    isEnabled = adbEnabled == 1
                } catch (e: Exception) {
                    // Method 2 failed, try method 3
                }
            }
            
            // Method 3: Check if app is debuggable (alternative indicator)
            if (!isEnabled) {
                try {
                    val pm = activity.packageManager
                    val appInfo = pm.getApplicationInfo(activity.packageName, PackageManager.GET_META_DATA)
                    // This checks if the app itself is debuggable, which might indicate dev environment
                    val isDebuggable = (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_DEBUGGABLE) != 0
                    isEnabled = isDebuggable
                } catch (e: Exception) {
                    // All methods failed
                }
            }
            
            isEnabled
        } catch (e: Exception) {
            false
        }
    }
}