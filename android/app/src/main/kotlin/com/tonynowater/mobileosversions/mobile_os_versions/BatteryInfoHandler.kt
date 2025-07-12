package com.tonynowater.mobileosversions.mobile_os_versions // 請替換成你的 package name

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

// 專門處理電池資訊的類別
class BatteryInfoHandler(private val context: Context) {

    private var batteryManager: BatteryManager =
        context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    private var chargingStateChangeReceiver: BroadcastReceiver? = null

    fun handle(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        if (call.method == "getBatteryInfo") {
            getBatteryInfo(result)
        } else {
            result.notImplemented()
        }
    }

    private fun getBatteryInfo(result: MethodChannel.Result) {
        val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct =
            if (level == -1 || scale == -1) 50.0f else level.toFloat() / scale.toFloat() * 100.0f

        result.success("電池電量: ${batteryPct.toInt()}%")
    }

    /** Gets battery information*/
    private fun getBatteryInfo(intent: Intent): Map<String, Any?> {
        var chargingStatus = getChargingStatus(intent)
        val voltage = intent.getIntExtra(BatteryManager.EXTRA_VOLTAGE, -1)
        val health = getBatteryHealth(intent)
        val pluggedStatus = getBatteryPluggedStatus(intent)
        var batteryLevel = -1
        var batteryCapacity = -1
        var currentAverage = -1
        var currentNow = -1
        var present = intent.extras?.getBoolean(BatteryManager.EXTRA_PRESENT);
        var scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, 0);
        var remainingEnergy = -1;
        var technology = intent.extras?.getString(BatteryManager.EXTRA_TECHNOLOGY);
        batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        batteryCapacity =
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
        currentAverage =
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_AVERAGE)
        currentNow = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CURRENT_NOW)
        remainingEnergy =
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_ENERGY_COUNTER);

        val chargeTimeRemaining = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            batteryManager.computeChargeTimeRemaining()
        } else {
            -1
        }
        val temperature = intent.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0)
        return mapOf(
            "batteryLevel" to batteryLevel,
            "batteryCapacity" to batteryCapacity,
            "chargeTimeRemaining" to chargeTimeRemaining,
            "chargingStatus" to chargingStatus,
            "currentAverage" to currentAverage,
            "currentNow" to currentNow,
            "health" to health,
            "present" to present,
            "pluggedStatus" to pluggedStatus,
            "remainingEnergy" to remainingEnergy,
            "scale" to scale,
            "technology" to technology,
            "temperature" to temperature / 10,
            "voltage" to voltage
        )
    }

    /** Gets the current charging state of the device */
    private fun getChargingStatus(intent: Intent): String {
        return when (intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
            BatteryManager.BATTERY_STATUS_FULL -> "full"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
            else -> {
                "unknown"
            }
        }
    }

    /** Gets the battery health */
    private fun getBatteryHealth(intent: Intent): String {
        return when (intent.getIntExtra(BatteryManager.EXTRA_HEALTH, -1)) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "health_good"
            BatteryManager.BATTERY_HEALTH_DEAD -> "dead"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "over_heat"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "over_voltage"
            BatteryManager.BATTERY_HEALTH_COLD -> "cold"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "unspecified_failure"
            else -> {
                "unknown"
            }
        }
    }

    /** Gets the battery plugged status */
    private fun getBatteryPluggedStatus(intent: Intent): String {
        return when (intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)) {
            BatteryManager.BATTERY_PLUGGED_USB -> "USB"
            BatteryManager.BATTERY_PLUGGED_AC -> "AC"
            BatteryManager.BATTERY_PLUGGED_WIRELESS -> "wireless"
            else -> {
                "unknown"
            }
        }
    }

    fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        chargingStateChangeReceiver = createChargingStateChangeReceiver(events);
        context.registerReceiver(
            chargingStateChangeReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        );
    }

    fun onCancel(arguments: Any?) {
        context.unregisterReceiver(chargingStateChangeReceiver);
        chargingStateChangeReceiver = null;
    }

    /** Creates broadcast receiver object that provides battery information upon subscription to the stream */
    private fun createChargingStateChangeReceiver(events: EventChannel.EventSink?): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(contxt: Context?, intent: Intent?) {
                events?.success(intent?.let { getBatteryInfo(it) })
            }
        }
    }
}