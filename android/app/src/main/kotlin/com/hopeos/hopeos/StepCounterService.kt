package com.hopeos.hopeos

import android.content.Context
import android.content.SharedPreferences
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Reads steps from the device's built-in step counter sensor
 * (TYPE_STEP_COUNTER). Works on virtually all modern Android
 * devices without needing Health Connect.
 *
 * The sensor reports total steps since last reboot, so we store
 * a daily baseline to compute today's step count.
 */
class StepCounterService(private val context: Context) : SensorEventListener {

    companion object {
        private const val TAG = "StepCounterService"
        private const val PREFS_NAME = "hopeos_step_counter"
        private const val KEY_BASELINE = "step_baseline"
        private const val KEY_BASELINE_DATE = "step_baseline_date"
        private const val KEY_TODAY_STEPS = "today_steps"
        private const val KEY_TODAY_DATE = "today_date"
    }

    private val sensorManager = context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val stepSensor: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
    private val prefs: SharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    val isAvailable: Boolean get() = stepSensor != null

    private var listening = false

    fun startListening() {
        if (stepSensor == null || listening) return
        sensorManager.registerListener(this, stepSensor, SensorManager.SENSOR_DELAY_NORMAL)
        listening = true
        Log.d(TAG, "Started listening to step counter sensor")
    }

    fun stopListening() {
        if (!listening) return
        sensorManager.unregisterListener(this)
        listening = false
        Log.d(TAG, "Stopped listening to step counter sensor")
    }

    fun getTodaySteps(): Int {
        val today = todayKey()
        val savedDate = prefs.getString(KEY_TODAY_DATE, null)
        return if (savedDate == today) {
            prefs.getInt(KEY_TODAY_STEPS, 0)
        } else {
            0
        }
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event?.sensor?.type != Sensor.TYPE_STEP_COUNTER) return

        val totalStepsSinceBoot = event.values[0].toInt()
        val today = todayKey()
        val savedDate = prefs.getString(KEY_BASELINE_DATE, null)

        if (savedDate != today) {
            // New day: reset baseline to current total
            prefs.edit()
                .putInt(KEY_BASELINE, totalStepsSinceBoot)
                .putString(KEY_BASELINE_DATE, today)
                .putInt(KEY_TODAY_STEPS, 0)
                .putString(KEY_TODAY_DATE, today)
                .apply()
            Log.d(TAG, "New day baseline: $totalStepsSinceBoot")
        } else {
            val baseline = prefs.getInt(KEY_BASELINE, totalStepsSinceBoot)
            val todaySteps = (totalStepsSinceBoot - baseline).coerceAtLeast(0)
            prefs.edit()
                .putInt(KEY_TODAY_STEPS, todaySteps)
                .putString(KEY_TODAY_DATE, today)
                .apply()
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun todayKey(): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd", Locale.US)
        return sdf.format(Date())
    }
}
