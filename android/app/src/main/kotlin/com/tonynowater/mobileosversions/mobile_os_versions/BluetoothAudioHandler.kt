package com.tonynowater.mobileosversions.mobile_os_versions

import android.app.Activity
import android.bluetooth.BluetoothA2dp
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothProfile
import android.os.Build
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BluetoothAudioHandler(private val activity: Activity) {
    private var bluetoothA2dp: BluetoothA2dp? = null
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var pendingResult: MethodChannel.Result? = null

    private val profileListener = object : BluetoothProfile.ServiceListener {
        override fun onServiceConnected(profile: Int, proxy: BluetoothProfile) {
            if (profile == BluetoothProfile.A2DP) {
                bluetoothA2dp = proxy as BluetoothA2dp
                // 如果有待處理的請求，現在處理它
                pendingResult?.let { result ->
                    getBluetoothAudioInfo(result)
                    pendingResult = null
                }
            }
        }

        override fun onServiceDisconnected(profile: Int) {
            if (profile == BluetoothProfile.A2DP) {
                bluetoothA2dp = null
            }
        }
    }

    fun init() {
        bluetoothAdapter?.getProfileProxy(activity, profileListener, BluetoothProfile.A2DP)
    }

    fun release() {
        bluetoothAdapter?.closeProfileProxy(BluetoothProfile.A2DP, bluetoothA2dp)
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBluetoothAudioInfo" -> getBluetoothAudioInfo(result)
            else -> result.notImplemented()
        }
    }

    private fun getBluetoothAudioInfo(result: MethodChannel.Result) {
        // 檢查 Android 版本
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            result.success(mapOf(
                "error" to "unsupported",
                "reason" to "Android 8.0 以下不支援"
            ))
            return
        }

        // 檢查藍牙適配器
        if (bluetoothAdapter == null) {
            result.success(mapOf(
                "error" to "no_adapter",
                "reason" to "此裝置不支援藍牙"
            ))
            return
        }

        // 檢查藍牙是否開啟
        if (!bluetoothAdapter.isEnabled) {
            result.success(mapOf(
                "error" to "bluetooth_off",
                "reason" to "請開啟藍牙"
            ))
            return
        }

        // 如果 A2DP proxy 尚未就緒，儲存請求稍後處理
        if (bluetoothA2dp == null) {
            pendingResult = result
            return
        }

        try {
            // 取得已連接的 A2DP 裝置清單
            val connectedDevices = bluetoothA2dp?.connectedDevices ?: emptyList()

            if (connectedDevices.isEmpty()) {
                result.success(mapOf(
                    "error" to "no_device",
                    "reason" to "無已連接的藍牙音訊裝置"
                ))
                return
            }

            // 使用第一個已連接的裝置
            val device = connectedDevices[0]
            val codecInfo = getCodecInfo(device)

            // 如果取得 codec 資訊時發生錯誤
            if (codecInfo.containsKey("error")) {
                result.success(codecInfo)
                return
            }

            // 建立完整的裝置資訊 Map
            val deviceInfo = mutableMapOf<String, Any>(
                "deviceName" to (device.name ?: "未知裝置"),
                "deviceAddress" to device.address
            )

            // 嘗試取得電量
            val batteryLevel = getBatteryLevel(device)
            deviceInfo["batteryLevel"] = batteryLevel

            // 合併 codec 資訊
            deviceInfo.putAll(codecInfo)

            result.success(deviceInfo)

        } catch (e: SecurityException) {
            result.success(mapOf(
                "error" to "permission_denied",
                "reason" to "缺少藍牙權限：${e.message}"
            ))
        } catch (e: Exception) {
            result.success(mapOf(
                "error" to "unknown",
                "reason" to (e.message ?: "未知錯誤")
            ))
        }
    }

    private fun getCodecInfo(device: BluetoothDevice): Map<String, Any> {
        val result = mutableMapOf<String, Any>()

        try {
            // 使用 reflection 存取 hidden API
            val getCodecStatusMethod = BluetoothA2dp::class.java.getMethod(
                "getCodecStatus",
                BluetoothDevice::class.java
            )
            val codecStatus = getCodecStatusMethod.invoke(bluetoothA2dp, device)

            if (codecStatus == null) {
                result["error"] = "codec_status_null"
                result["reason"] = "無法取得 codec 狀態"
                return result
            }

            val getCodecConfigMethod = codecStatus.javaClass.getMethod("getCodecConfig")
            val codecConfig = getCodecConfigMethod.invoke(codecStatus)

            if (codecConfig == null) {
                result["error"] = "codec_config_null"
                result["reason"] = "無法取得 codec 設定"
                return result
            }

            // 取得各項 codec 資訊
            val getCodecType = codecConfig.javaClass.getMethod("getCodecType")
            val getSampleRate = codecConfig.javaClass.getMethod("getSampleRate")
            val getBitsPerSample = codecConfig.javaClass.getMethod("getBitsPerSample")
            val getChannelMode = codecConfig.javaClass.getMethod("getChannelMode")

            val codecType = getCodecType.invoke(codecConfig) as Int
            val sampleRate = getSampleRate.invoke(codecConfig) as Int
            val bitsPerSample = getBitsPerSample.invoke(codecConfig) as Int
            val channelMode = getChannelMode.invoke(codecConfig) as Int

            // 嘗試取得 codecSpecific1 (用於 bitrate)
            var codecSpecific1: Long = 0
            try {
                val getCodecSpecific1 = codecConfig.javaClass.getMethod("getCodecSpecific1")
                codecSpecific1 = getCodecSpecific1.invoke(codecConfig) as Long
            } catch (e: Exception) {
                // 某些 Android 版本可能沒有此方法
            }

            result["codecType"] = BluetoothCodecConstants.codecTypeToString(codecType)
            result["sampleRate"] = BluetoothCodecConstants.sampleRateToString(sampleRate)
            result["bitsPerSample"] = BluetoothCodecConstants.bitsPerSampleToString(bitsPerSample)
            result["channelMode"] = BluetoothCodecConstants.channelModeToString(channelMode)
            result["bitrate"] = BluetoothCodecConstants.bitrateToString(codecType, codecSpecific1)

        } catch (e: NoSuchMethodException) {
            result["error"] = "method_not_found"
            result["reason"] = "此裝置不支援 codec 資訊存取：${e.message}"
        } catch (e: Exception) {
            result["error"] = "reflection_failed"
            result["reason"] = "取得 codec 資訊失敗：${e.message}"
        }

        return result
    }

    private fun getBatteryLevel(device: BluetoothDevice): Int {
        return try {
            // 嘗試透過 reflection 存取 getBatteryLevel (hidden API)
            val getBatteryLevelMethod = BluetoothDevice::class.java.getMethod("getBatteryLevel")
            val level = getBatteryLevelMethod.invoke(device) as? Int ?: -1
            level
        } catch (e: Exception) {
            -1 // 不支援或取得失敗
        }
    }
}

object BluetoothCodecConstants {
    // Codec Types
    const val SOURCE_CODEC_TYPE_SBC = 0
    const val SOURCE_CODEC_TYPE_AAC = 1
    const val SOURCE_CODEC_TYPE_APTX = 2
    const val SOURCE_CODEC_TYPE_APTX_HD = 3
    const val SOURCE_CODEC_TYPE_LDAC = 4
    const val SOURCE_CODEC_TYPE_OPUS = 5
    const val SOURCE_CODEC_TYPE_LC3 = 6
    const val SOURCE_CODEC_TYPE_INVALID = 1000000

    // Sample Rates (bitmask)
    const val SAMPLE_RATE_NONE = 0
    const val SAMPLE_RATE_44100 = 0x01
    const val SAMPLE_RATE_48000 = 0x02
    const val SAMPLE_RATE_88200 = 0x04
    const val SAMPLE_RATE_96000 = 0x08
    const val SAMPLE_RATE_176400 = 0x10
    const val SAMPLE_RATE_192000 = 0x20

    // Bits Per Sample (bitmask)
    const val BITS_PER_SAMPLE_NONE = 0
    const val BITS_PER_SAMPLE_16 = 0x01
    const val BITS_PER_SAMPLE_24 = 0x02
    const val BITS_PER_SAMPLE_32 = 0x04

    // Channel Mode (bitmask)
    const val CHANNEL_MODE_NONE = 0
    const val CHANNEL_MODE_MONO = 0x01
    const val CHANNEL_MODE_STEREO = 0x02

    fun codecTypeToString(type: Int): String = when (type) {
        SOURCE_CODEC_TYPE_SBC -> "SBC"
        SOURCE_CODEC_TYPE_AAC -> "AAC"
        SOURCE_CODEC_TYPE_APTX -> "aptX"
        SOURCE_CODEC_TYPE_APTX_HD -> "aptX HD"
        SOURCE_CODEC_TYPE_LDAC -> "LDAC"
        SOURCE_CODEC_TYPE_OPUS -> "Opus"
        SOURCE_CODEC_TYPE_LC3 -> "LC3"
        else -> "Unknown"
    }

    fun sampleRateToString(rate: Int): String = when (rate) {
        SAMPLE_RATE_44100 -> "44.1 kHz"
        SAMPLE_RATE_48000 -> "48 kHz"
        SAMPLE_RATE_88200 -> "88.2 kHz"
        SAMPLE_RATE_96000 -> "96 kHz"
        SAMPLE_RATE_176400 -> "176.4 kHz"
        SAMPLE_RATE_192000 -> "192 kHz"
        else -> "Unknown"
    }

    fun bitsPerSampleToString(bits: Int): String = when (bits) {
        BITS_PER_SAMPLE_16 -> "16 bit"
        BITS_PER_SAMPLE_24 -> "24 bit"
        BITS_PER_SAMPLE_32 -> "32 bit"
        else -> "Unknown"
    }

    fun channelModeToString(mode: Int): String = when (mode) {
        CHANNEL_MODE_MONO -> "Mono"
        CHANNEL_MODE_STEREO -> "Stereo"
        else -> "Unknown"
    }

    fun bitrateToString(codecType: Int, codecSpecific1: Long): String {
        return when (codecType) {
            SOURCE_CODEC_TYPE_LDAC -> {
                // LDAC bitrate 根據 codecSpecific1 判斷
                when (codecSpecific1) {
                    1000L -> "990 kbps (最高品質)"
                    660L -> "660 kbps (標準)"
                    330L -> "330 kbps (連接優先)"
                    0L, -1L -> "ABR (自適應)"
                    else -> "ABR (自適應)"
                }
            }
            SOURCE_CODEC_TYPE_APTX_HD -> {
                // aptX HD 固定位元率
                "576 kbps"
            }
            SOURCE_CODEC_TYPE_APTX -> {
                // aptX 固定位元率
                "352 kbps"
            }
            SOURCE_CODEC_TYPE_AAC -> {
                // AAC 可變位元率
                "約 256 kbps"
            }
            SOURCE_CODEC_TYPE_SBC -> {
                // SBC 可變位元率
                "約 328 kbps"
            }
            else -> "不支援"
        }
    }
}
