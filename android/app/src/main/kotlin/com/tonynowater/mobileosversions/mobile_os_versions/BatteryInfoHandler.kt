package com.tonynowater.mobileosversions.mobile_os_versions

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class BatteryInfoHandler(private val context: Context) : EventChannel.StreamHandler {

    private var events: EventChannel.EventSink? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        val chargingStatus = getChargingStatus(context)
        val capacity = batteryManager.getLongProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER).toString()
        val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val technology = intent?.getStringExtra(BatteryManager.EXTRA_TECHNOLOGY) ?: "Unknown"
        val temperature = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0)?.div(10.0).toString()
        val health = getHealth(intent?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0))

        val map = mapOf(
            "batteryLevel" to batteryLevel.toString(),
            "chargingStatus" to chargingStatus,
            "capacity" to capacity,
            "technology" to technology,
            "temperature" to temperature,
            "health" to health
        )
        result.success(map)
    }

    private fun getChargingStatus(context: Context): String {
        val intent = context.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        return when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "charging"
            BatteryManager.BATTERY_STATUS_FULL -> "full"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "discharging"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "not charging"
            else -> "unknown"
        }
    }

    private fun getHealth(health: Int?): String {
        return when (health) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "good"
            BatteryManager.BATTERY_HEALTH_DEAD -> "dead"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "over_heat"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "over_voltage"
            BatteryManager.BATTERY_HEALTH_COLD -> "cold"
            else -> "unspecified_failure"
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.events = events
    }

    override fun onCancel(arguments: Any?) {
        this.events = null
    }
}