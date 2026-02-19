package com.tonynowater.mobileosversions.mobile_os_versions

import android.app.Activity
import android.bluetooth.BluetoothA2dp
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothProfile
import android.companion.AssociationRequest
import android.companion.BluetoothDeviceFilter
import android.companion.CompanionDeviceManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.IntentSender
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BluetoothAudioHandler(private val activity: Activity) {
    private var bluetoothA2dp: BluetoothA2dp? = null
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()
    private var pendingResult: MethodChannel.Result? = null

    // TWS 電量快取: key = device MAC address, value = {batteryLeft, batteryRight, batteryCase}
    private val twsBatteryCache = mutableMapOf<String, MutableMap<String, Int>>()

    companion object {
        private const val TAG = "BluetoothAudioHandler"
        const val REQUEST_CODE_CDM_ASSOCIATION = 1001
    }

    // Callback for CDM association result
    private var cdmAssociationCallback: ((Boolean) -> Unit)? = null

    // BroadcastReceiver for battery level changes (Strategy 3)
    private val batteryLevelReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null) return
            val action = intent.action ?: return

            val device = if (Build.VERSION.SDK_INT >= 33) {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
            } ?: return

            val address = device.address ?: return
            Log.d(TAG, "BatteryReceiver: action=$action, device=$address")

            val cache = twsBatteryCache.getOrPut(address) {
                mutableMapOf("batteryLeft" to -1, "batteryRight" to -1, "batteryCase" to -1)
            }

            when (action) {
                "android.bluetooth.device.action.BATTERY_LEVEL_CHANGED" -> {
                    // 標準 ACTION_BATTERY_LEVEL_CHANGED 只含整體電量
                    // 嘗試讀取 OEM 自訂的 untethered extras
                    val left = intent.getIntExtra("android.bluetooth.device.extra.HEADSET_BATTERY_LEFT", -1)
                    val right = intent.getIntExtra("android.bluetooth.device.extra.HEADSET_BATTERY_RIGHT", -1)
                    val case_ = intent.getIntExtra("android.bluetooth.device.extra.HEADSET_BATTERY_CASE", -1)
                    if (left != -1 || right != -1 || case_ != -1) {
                        cache["batteryLeft"] = left
                        cache["batteryRight"] = right
                        cache["batteryCase"] = case_
                        Log.d(TAG, "BatteryReceiver: TWS levels cached from extras: L=$left R=$right C=$case_")
                    }
                }
                // Samsung / Google Pixel OEM TWS battery action
                "android.bluetooth.headset.action.HF_INDICATORS_VALUE_CHANGED",
                "android.bluetooth.headset.profile.action.HF_INDICATORS_VALUE_CHANGED" -> {
                    val left = intent.getIntExtra("android.bluetooth.device.extra.HEADSET_BATTERY_LEFT", -1)
                    val right = intent.getIntExtra("android.bluetooth.device.extra.HEADSET_BATTERY_RIGHT", -1)
                    val case_ = intent.getIntExtra("android.bluetooth.device.extra.HEADSET_BATTERY_CASE", -1)
                    if (left != -1 || right != -1 || case_ != -1) {
                        cache["batteryLeft"] = left
                        cache["batteryRight"] = right
                        cache["batteryCase"] = case_
                        Log.d(TAG, "BatteryReceiver: TWS levels cached from HF_INDICATORS: L=$left R=$right C=$case_")
                    }
                }
            }
        }
    }

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

        // 策略 3: 註冊 BroadcastReceiver 監聽電量變化
        val filter = IntentFilter().apply {
            addAction("android.bluetooth.device.action.BATTERY_LEVEL_CHANGED")
            addAction("android.bluetooth.headset.action.HF_INDICATORS_VALUE_CHANGED")
            addAction("android.bluetooth.headset.profile.action.HF_INDICATORS_VALUE_CHANGED")
        }
        try {
            if (Build.VERSION.SDK_INT >= 33) {
                activity.registerReceiver(batteryLevelReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                activity.registerReceiver(batteryLevelReceiver, filter)
            }
            Log.d(TAG, "BatteryLevelReceiver registered")
        } catch (e: Exception) {
            Log.w(TAG, "Failed to register BatteryLevelReceiver: ${e.message}")
        }
    }

    fun release() {
        bluetoothAdapter?.closeProfileProxy(BluetoothProfile.A2DP, bluetoothA2dp)

        // 取消註冊 BroadcastReceiver
        try {
            activity.unregisterReceiver(batteryLevelReceiver)
            Log.d(TAG, "BatteryLevelReceiver unregistered")
        } catch (e: Exception) {
            Log.w(TAG, "Failed to unregister BatteryLevelReceiver: ${e.message}")
        }
    }

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getBluetoothAudioInfo" -> getBluetoothAudioInfo(result)
            "setBluetoothCodecConfig" -> setBluetoothCodecConfig(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * Handle the result from CDM association intent.
     * Called from MainActivity.onActivityResult().
     */
    fun onCdmAssociationResult(resultCode: Int) {
        val success = resultCode == Activity.RESULT_OK
        Log.d(TAG, "CDM association result: success=$success")
        cdmAssociationCallback?.invoke(success)
        cdmAssociationCallback = null
    }

    /**
     * Ensure CDM association exists for the given device.
     * Only runs on Android 16+ (API 36+) where CDM association is required for codec access.
     *
     * @param device The Bluetooth device to associate
     * @param callback Called with true if association exists/succeeded, false otherwise
     */
    private fun ensureCdmAssociation(device: BluetoothDevice, callback: (Boolean) -> Unit) {
        if (Build.VERSION.SDK_INT < 36) {
            callback(true)
            return
        }

        try {
            val companionDeviceManager = activity.getSystemService(Context.COMPANION_DEVICE_SERVICE) as? CompanionDeviceManager
            if (companionDeviceManager == null) {
                Log.w(TAG, "CompanionDeviceManager not available")
                callback(false)
                return
            }

            // Check if association already exists
            val existingAssociations = companionDeviceManager.associations
            if (existingAssociations.any { it.equals(device.address, ignoreCase = true) }) {
                Log.d(TAG, "CDM association already exists for ${device.address}")
                callback(true)
                return
            }

            // Build association request for the specific device
            Log.d(TAG, "Requesting CDM association for ${device.address}")
            val deviceFilter = BluetoothDeviceFilter.Builder()
                .setAddress(device.address)
                .build()
            val pairingRequest = AssociationRequest.Builder()
                .addDeviceFilter(deviceFilter)
                .setSingleDevice(true)
                .build()

            cdmAssociationCallback = callback

            if (Build.VERSION.SDK_INT >= 33) {
                // API 33+ uses Executor-based callback
                companionDeviceManager.associate(
                    pairingRequest,
                    activity.mainExecutor,
                    object : CompanionDeviceManager.Callback() {
                        override fun onDeviceFound(chooserLauncher: IntentSender) {
                            try {
                                activity.startIntentSenderForResult(
                                    chooserLauncher,
                                    REQUEST_CODE_CDM_ASSOCIATION,
                                    null, 0, 0, 0
                                )
                            } catch (e: Exception) {
                                Log.e(TAG, "Failed to launch CDM chooser", e)
                                cdmAssociationCallback?.invoke(false)
                                cdmAssociationCallback = null
                            }
                        }

                        override fun onFailure(error: CharSequence?) {
                            Log.w(TAG, "CDM association failed: $error")
                            cdmAssociationCallback?.invoke(false)
                            cdmAssociationCallback = null
                        }
                    }
                )
            } else {
                // API 26-32 uses Handler-based callback
                @Suppress("DEPRECATION")
                companionDeviceManager.associate(
                    pairingRequest,
                    object : CompanionDeviceManager.Callback() {
                        override fun onDeviceFound(chooserLauncher: IntentSender) {
                            try {
                                activity.startIntentSenderForResult(
                                    chooserLauncher,
                                    REQUEST_CODE_CDM_ASSOCIATION,
                                    null, 0, 0, 0
                                )
                            } catch (e: Exception) {
                                Log.e(TAG, "Failed to launch CDM chooser", e)
                                cdmAssociationCallback?.invoke(false)
                                cdmAssociationCallback = null
                            }
                        }

                        override fun onFailure(error: CharSequence?) {
                            Log.w(TAG, "CDM association failed: $error")
                            cdmAssociationCallback?.invoke(false)
                            cdmAssociationCallback = null
                        }
                    },
                    Handler(Looper.getMainLooper())
                )
            }
        } catch (e: Exception) {
            Log.e(TAG, "CDM association error", e)
            callback(false)
        }
    }

    private fun setBluetoothCodecConfig(call: MethodCall, result: MethodChannel.Result) {
        val codecType = call.argument<Int>("codecType") ?: run {
            result.success(mapOf("success" to false, "error" to "Missing codecType"))
            return
        }
        val sampleRate = call.argument<Int>("sampleRate") ?: run {
            result.success(mapOf("success" to false, "error" to "Missing sampleRate"))
            return
        }
        val bitsPerSample = call.argument<Int>("bitsPerSample") ?: run {
            result.success(mapOf("success" to false, "error" to "Missing bitsPerSample"))
            return
        }
        val channelMode = call.argument<Int>("channelMode") ?: run {
            result.success(mapOf("success" to false, "error" to "Missing channelMode"))
            return
        }
        val codecSpecific1 = call.argument<Number>("codecSpecific1")?.toLong() ?: 0L

        try {
            val a2dp = bluetoothA2dp
            if (a2dp == null) {
                result.success(mapOf("success" to false, "error" to "A2DP not connected"))
                return
            }

            val connectedDevices = a2dp.connectedDevices
            if (connectedDevices.isEmpty()) {
                result.success(mapOf("success" to false, "error" to "No connected device"))
                return
            }

            val device = connectedDevices[0]

            // Android 16+: ensure CDM association
            if (Build.VERSION.SDK_INT >= 36) {
                ensureCdmAssociation(device) { _ -> }
            }

            // Build BluetoothCodecConfig via reflection
            val codecConfig: Any = if (Build.VERSION.SDK_INT >= 33) {
                // API 33+: use BluetoothCodecConfig.Builder
                val builderClass = Class.forName("android.bluetooth.BluetoothCodecConfig\$Builder")
                val builder = builderClass.getConstructor().newInstance()
                builderClass.getMethod("setCodecType", Int::class.java).invoke(builder, codecType)
                builderClass.getMethod("setCodecPriority", Int::class.java).invoke(builder, 1000000 /*CODEC_PRIORITY_HIGHEST*/)
                builderClass.getMethod("setSampleRate", Int::class.java).invoke(builder, sampleRate)
                builderClass.getMethod("setBitsPerSample", Int::class.java).invoke(builder, bitsPerSample)
                builderClass.getMethod("setChannelMode", Int::class.java).invoke(builder, channelMode)
                builderClass.getMethod("setCodecSpecific1", Long::class.java).invoke(builder, codecSpecific1)
                builderClass.getMethod("build").invoke(builder)!!
            } else {
                // API 26-32: use constructor
                val configClass = Class.forName("android.bluetooth.BluetoothCodecConfig")
                val constructor = configClass.getConstructor(
                    Int::class.java, Int::class.java, Int::class.java, Int::class.java, Int::class.java,
                    Long::class.java, Long::class.java, Long::class.java, Long::class.java
                )
                constructor.newInstance(
                    codecType, 1000000 /*CODEC_PRIORITY_HIGHEST*/, sampleRate, bitsPerSample, channelMode,
                    codecSpecific1, 0L, 0L, 0L
                )!!
            }

            // Call setCodecConfigPreference via reflection
            val setMethod = BluetoothA2dp::class.java.getMethod(
                "setCodecConfigPreference",
                BluetoothDevice::class.java,
                Class.forName("android.bluetooth.BluetoothCodecConfig")
            )
            setMethod.invoke(a2dp, device, codecConfig)

            result.success(mapOf("success" to true))

        } catch (e: Exception) {
            val cause = if (e is java.lang.reflect.InvocationTargetException) e.cause else e
            Log.e(TAG, "setBluetoothCodecConfig failed", cause ?: e)
            result.success(mapOf("success" to false, "error" to (cause?.message ?: e.message ?: "Unknown error")))
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

            // Android 16+ (API 36): 嘗試建立 CDM association（非阻塞）
            if (Build.VERSION.SDK_INT >= 36) {
                ensureCdmAssociation(device) { success ->
                    Log.d(TAG, "CDM association ensured: $success")
                    // 無論成功與否都繼續取得 codec 資訊
                    // 失敗時 getCodecInfo 會捕獲 SecurityException 並優雅降級
                }
            }

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

            // 嘗試取得 TWS 分離電量
            deviceInfo.putAll(getUntetheredBatteryLevels(device))

            // 推斷藍牙版本
            deviceInfo["bluetoothVersion"] = inferBluetoothVersion()

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

            // 回傳原始 int 值，供 Flutter 端建構 setCodecConfig 請求
            result["currentCodecType"] = codecType
            result["currentSampleRate"] = sampleRate
            result["currentBitsPerSample"] = bitsPerSample
            result["currentChannelMode"] = channelMode
            result["currentCodecSpecific1"] = codecSpecific1

            // 嘗試取得 selectable capabilities
            try {
                val getSelectableMethod = codecStatus.javaClass.getMethod("getCodecsSelectableCapabilities")
                val selectableCapabilities = getSelectableMethod.invoke(codecStatus) as? List<*>
                if (selectableCapabilities != null) {
                    // 找出與當前 codecType 相同的 selectable capability
                    for (cap in selectableCapabilities) {
                        if (cap == null) continue
                        val capCodecType = cap.javaClass.getMethod("getCodecType").invoke(cap) as Int
                        if (capCodecType == codecType) {
                            val capSampleRate = cap.javaClass.getMethod("getSampleRate").invoke(cap) as Int
                            val capBitsPerSample = cap.javaClass.getMethod("getBitsPerSample").invoke(cap) as Int
                            val capChannelMode = cap.javaClass.getMethod("getChannelMode").invoke(cap) as Int

                            result["selectableSampleRates"] = BluetoothCodecConstants.parseSampleRateBitmask(capSampleRate)
                            result["selectableBitsPerSample"] = BluetoothCodecConstants.parseBitsPerSampleBitmask(capBitsPerSample)
                            result["selectableChannelModes"] = BluetoothCodecConstants.parseChannelModeBitmask(capChannelMode)
                            break
                        }
                    }
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to get selectable capabilities: ${e.message}")
                // 不影響原有功能，只是不回傳 selectable 欄位
            }

        } catch (e: NoSuchMethodException) {
            result["error"] = "method_not_found"
            result["reason"] = "此裝置不支援 codec 資訊存取：${e.message}"
        } catch (e: java.lang.reflect.InvocationTargetException) {
            // Reflection 呼叫時目標方法拋出的異常
            val cause = e.cause
            // Android 16+ CDM SecurityException: 優雅降級為 Unknown 值
            if (cause is SecurityException && (cause.message?.contains("CDM", ignoreCase = true) == true
                        || cause.message?.contains("associate", ignoreCase = true) == true
                        || Build.VERSION.SDK_INT >= 36)) {
                Log.w(TAG, "CDM SecurityException on API ${Build.VERSION.SDK_INT}, degrading gracefully", cause)
                result["codecType"] = "Unknown (需要裝置配對)"
                result["sampleRate"] = "Unknown"
                result["bitsPerSample"] = "Unknown"
                result["channelMode"] = "Unknown"
                result["bitrate"] = "Unknown"
                // 不設定 error key，讓前端當作成功回應但 codec 值為 Unknown
            } else {
                result["error"] = "invocation_failed"
                result["reason"] = "Codec API 呼叫失敗：${cause?.javaClass?.simpleName ?: "Unknown"} - ${cause?.message ?: e.message}"
            }
        } catch (e: SecurityException) {
            // Android 9+ hidden API 存取限制
            result["error"] = "security_exception"
            result["reason"] = "API 存取被限制（Android ${Build.VERSION.SDK_INT}）：${e.message}"
        } catch (e: IllegalAccessException) {
            // Hidden API 存取權限問題
            result["error"] = "access_denied"
            result["reason"] = "無法存取 hidden API：${e.message}"
        } catch (e: Exception) {
            result["error"] = "reflection_failed"
            result["reason"] = "取得 codec 資訊失敗（${e.javaClass.simpleName}）：${e.message}"
        }

        return result
    }

    private fun inferBluetoothVersion(): String {
        val adapter = bluetoothAdapter ?: return "Unknown"
        return try {
            // API 33+: 檢查 LE Audio 支援 → BT 5.2+
            if (Build.VERSION.SDK_INT >= 33) {
                val leAudioSupported = adapter.isLeAudioSupported
                // BluetoothStatusCodes.FEATURE_SUPPORTED = 1
                if (leAudioSupported == 1) {
                    return "5.2+"
                }
            }
            // API 26+: 檢查 LE 2M PHY 或 LE Coded PHY 支援 → BT 5.0+
            if (adapter.isLe2MPhySupported || adapter.isLeCodedPhySupported ||
                adapter.isLeExtendedAdvertisingSupported) {
                return "5.0+"
            }
            // Android 8.0+ 基本需要 BT 4.2
            "4.2+"
        } catch (e: Exception) {
            Log.w(TAG, "inferBluetoothVersion failed: ${e.message}")
            "Unknown"
        }
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

    /**
     * 判斷 TWS 電量 map 是否全為 -1（即未能取得任何資料）
     */
    private fun allNegative(map: Map<String, Int>): Boolean {
        return map["batteryLeft"] == -1 && map["batteryRight"] == -1 && map["batteryCase"] == -1
    }

    /**
     * 取得 TWS 耳機的左耳/右耳/充電盒電量，採用三層 fallback 策略：
     *
     * 策略 1: getMetadata() reflection（部分自訂 ROM 可能成功）
     * 策略 2: ContentProvider 查詢 content://com.android.bluetooth/device_meta_data
     * 策略 3: BroadcastReceiver 快取（從 ACTION_BATTERY_LEVEL_CHANGED 或 OEM broadcast 累積）
     *
     * 三層均失敗則回傳全 -1，UI 端判斷 -1 時不顯示拆分電量。
     */
    private fun getUntetheredBatteryLevels(device: BluetoothDevice): Map<String, Int> {
        val fallbackResult = mapOf("batteryLeft" to -1, "batteryRight" to -1, "batteryCase" to -1)

        if (Build.VERSION.SDK_INT < 28) {
            Log.d(TAG, "getUntetheredBatteryLevels: SDK < 28, skip all strategies")
            return fallbackResult
        }

        // ── 策略 1: getMetadata() reflection ────────────────────────────────
        // METADATA_UNTETHERED_LEFT_BATTERY = 6
        // METADATA_UNTETHERED_RIGHT_BATTERY = 7
        // METADATA_UNTETHERED_CASE_BATTERY = 8
        Log.d(TAG, "getUntetheredBatteryLevels: trying Strategy 1 (getMetadata reflection)")
        try {
            val getMetadata = BluetoothDevice::class.java.getMethod("getMetadata", Int::class.java)
            val left = (getMetadata.invoke(device, 6) as? ByteArray)?.let { String(it).toIntOrNull() } ?: -1
            val right = (getMetadata.invoke(device, 7) as? ByteArray)?.let { String(it).toIntOrNull() } ?: -1
            val case_ = (getMetadata.invoke(device, 8) as? ByteArray)?.let { String(it).toIntOrNull() } ?: -1
            Log.d(TAG, "Strategy 1 result: L=$left R=$right C=$case_")
            val strategy1 = mutableMapOf("batteryLeft" to left, "batteryRight" to right, "batteryCase" to case_)
            if (!allNegative(strategy1)) {
                Log.d(TAG, "Strategy 1 succeeded")
                return strategy1
            }
            Log.d(TAG, "Strategy 1 returned all -1, trying Strategy 2")
        } catch (e: Exception) {
            Log.w(TAG, "Strategy 1 (getMetadata) failed: ${e.javaClass.simpleName} - ${e.message}")
        }

        // ── 策略 2: ContentProvider 查詢 ─────────────────────────────────────
        // Android Bluetooth stack 將 device metadata 存放在 ContentProvider
        // URI: content://com.android.bluetooth/device_meta_data
        // 欄位: address, key, value (byte array)
        Log.d(TAG, "getUntetheredBatteryLevels: trying Strategy 2 (ContentProvider)")
        try {
            val uri = android.net.Uri.parse("content://com.android.bluetooth/device_meta_data")
            val cursor = activity.contentResolver.query(
                uri,
                arrayOf("key", "value"),
                "address = ?",
                arrayOf(device.address),
                null
            )
            cursor?.use { c ->
                val keyIdx = c.getColumnIndex("key")
                val valIdx = c.getColumnIndex("value")
                if (keyIdx >= 0 && valIdx >= 0) {
                    val strategy2 = mutableMapOf("batteryLeft" to -1, "batteryRight" to -1, "batteryCase" to -1)
                    while (c.moveToNext()) {
                        val key = c.getInt(keyIdx)
                        val valueBytes = c.getBlob(valIdx)
                        val valueStr = valueBytes?.let { String(it).trim() }
                        val valueInt = valueStr?.toIntOrNull() ?: -1
                        Log.d(TAG, "Strategy 2 row: key=$key value=$valueStr")
                        when (key) {
                            6 -> strategy2["batteryLeft"] = valueInt
                            7 -> strategy2["batteryRight"] = valueInt
                            8 -> strategy2["batteryCase"] = valueInt
                        }
                    }
                    if (!allNegative(strategy2)) {
                        Log.d(TAG, "Strategy 2 succeeded: ${strategy2}")
                        return strategy2
                    }
                    Log.d(TAG, "Strategy 2 returned all -1, trying Strategy 3")
                } else {
                    Log.d(TAG, "Strategy 2: cursor columns not found (key=$keyIdx, val=$valIdx)")
                }
            } ?: Log.d(TAG, "Strategy 2: cursor is null")
        } catch (e: SecurityException) {
            Log.w(TAG, "Strategy 2 (ContentProvider) SecurityException: ${e.message}")
        } catch (e: Exception) {
            Log.w(TAG, "Strategy 2 (ContentProvider) failed: ${e.javaClass.simpleName} - ${e.message}")
        }

        // ── 策略 3: BroadcastReceiver 快取 ───────────────────────────────────
        Log.d(TAG, "getUntetheredBatteryLevels: trying Strategy 3 (BroadcastReceiver cache)")
        val cached = twsBatteryCache[device.address]
        if (cached != null && !allNegative(cached)) {
            Log.d(TAG, "Strategy 3 succeeded (from cache): $cached")
            return cached.toMap()
        }
        Log.d(TAG, "Strategy 3: no valid TWS cache for ${device.address}")

        // 所有策略均失敗，gracefully 回傳 -1
        Log.d(TAG, "getUntetheredBatteryLevels: all strategies failed, returning -1")
        return fallbackResult
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

    fun parseSampleRateBitmask(bitmask: Int): List<Map<String, Any>> {
        val rates = mutableListOf<Map<String, Any>>()
        if (bitmask and SAMPLE_RATE_44100 != 0) rates.add(mapOf("value" to SAMPLE_RATE_44100, "label" to "44.1 kHz"))
        if (bitmask and SAMPLE_RATE_48000 != 0) rates.add(mapOf("value" to SAMPLE_RATE_48000, "label" to "48 kHz"))
        if (bitmask and SAMPLE_RATE_88200 != 0) rates.add(mapOf("value" to SAMPLE_RATE_88200, "label" to "88.2 kHz"))
        if (bitmask and SAMPLE_RATE_96000 != 0) rates.add(mapOf("value" to SAMPLE_RATE_96000, "label" to "96 kHz"))
        if (bitmask and SAMPLE_RATE_176400 != 0) rates.add(mapOf("value" to SAMPLE_RATE_176400, "label" to "176.4 kHz"))
        if (bitmask and SAMPLE_RATE_192000 != 0) rates.add(mapOf("value" to SAMPLE_RATE_192000, "label" to "192 kHz"))
        return rates
    }

    fun parseBitsPerSampleBitmask(bitmask: Int): List<Map<String, Any>> {
        val bits = mutableListOf<Map<String, Any>>()
        if (bitmask and BITS_PER_SAMPLE_16 != 0) bits.add(mapOf("value" to BITS_PER_SAMPLE_16, "label" to "16 bit"))
        if (bitmask and BITS_PER_SAMPLE_24 != 0) bits.add(mapOf("value" to BITS_PER_SAMPLE_24, "label" to "24 bit"))
        if (bitmask and BITS_PER_SAMPLE_32 != 0) bits.add(mapOf("value" to BITS_PER_SAMPLE_32, "label" to "32 bit"))
        return bits
    }

    fun parseChannelModeBitmask(bitmask: Int): List<Map<String, Any>> {
        val modes = mutableListOf<Map<String, Any>>()
        if (bitmask and CHANNEL_MODE_MONO != 0) modes.add(mapOf("value" to CHANNEL_MODE_MONO, "label" to "Mono"))
        if (bitmask and CHANNEL_MODE_STEREO != 0) modes.add(mapOf("value" to CHANNEL_MODE_STEREO, "label" to "Stereo"))
        return modes
    }

    fun bitrateToString(codecType: Int, codecSpecific1: Long): String {
        return when (codecType) {
            SOURCE_CODEC_TYPE_LDAC -> {
                // LDAC bitrate 根據 codecSpecific1 判斷
                when (codecSpecific1) {
                    0L -> "ABR (自適應)"      // Android returns 0 for ABR/Best Effort mode
                    1000L -> "990 kbps (最高品質)"
                    1001L -> "660 kbps (標準)"
                    1002L -> "330 kbps (連接優先)"
                    1003L -> "ABR (自適應)"
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
