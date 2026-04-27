package com.hopeos.hopeos

import android.Manifest
import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.os.Process
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar

class MainActivity : FlutterActivity() {
    private val PERMISSIONS_CHANNEL = "com.hopeos.app/permissions"
    private val SCREEN_TIME_CHANNEL = "com.hopeos.app/screen_time"
    private val SERVICE_CHANNEL = "com.hopeos.app/foreground_service"
    private val ACTIVITY_RECOGNITION_REQUEST_CODE = 1001

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Permissions channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PERMISSIONS_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestActivityRecognition" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                            if (ContextCompat.checkSelfPermission(
                                    this,
                                    Manifest.permission.ACTIVITY_RECOGNITION
                                ) == PackageManager.PERMISSION_GRANTED
                            ) {
                                result.success(true)
                            } else {
                                ActivityCompat.requestPermissions(
                                    this,
                                    arrayOf(Manifest.permission.ACTIVITY_RECOGNITION),
                                    ACTIVITY_RECOGNITION_REQUEST_CODE
                                )
                                result.success(true)
                            }
                        } else {
                            result.success(true)
                        }
                    }
                    "openUsageAccessSettings" -> {
                        try {
                            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Cannot open usage access settings", null)
                        }
                    }
                    "openAppSettings" -> {
                        try {
                            val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                            intent.data = android.net.Uri.fromParts("package", packageName, null)
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Cannot open app settings", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Foreground service channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SERVICE_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startService" -> {
                        try {
                            BootReceiver.setServiceEnabled(this, true)
                            QuickCaptureService.start(this)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    "stopService" -> {
                        try {
                            BootReceiver.setServiceEnabled(this, false)
                            QuickCaptureService.stop(this)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("SERVICE_ERROR", e.message, null)
                        }
                    }
                    "isServiceRunning" -> {
                        result.success(BootReceiver.isServiceEnabled(this))
                    }
                    "requestBatteryOptimizationExemption" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val pm = getSystemService(POWER_SERVICE) as PowerManager
                                if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                                    val intent = Intent(
                                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                        Uri.parse("package:$packageName")
                                    )
                                    startActivity(intent)
                                }
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("BATTERY_ERROR", e.message, null)
                        }
                    }
                    "isBatteryOptimizationExempt" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            result.success(pm.isIgnoringBatteryOptimizations(packageName))
                        } else {
                            result.success(true)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Screen time channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_TIME_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasUsageStatsPermission" -> {
                        result.success(hasUsageStatsPermission())
                    }
                    "openUsageAccessSettings" -> {
                        try {
                            startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNAVAILABLE", "Cannot open settings", null)
                        }
                    }
                    "getDailyScreenTime" -> {
                        if (!hasUsageStatsPermission()) {
                            result.success(null)
                            return@setMethodCallHandler
                        }

                        val year = call.argument<Int>("year") ?: 0
                        val month = call.argument<Int>("month") ?: 0
                        val day = call.argument<Int>("day") ?: 0

                        val data = getDailyScreenTime(year, month, day)
                        result.success(data)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getDailyScreenTime(year: Int, month: Int, day: Int): Map<String, Int> {
        val usageStatsManager =
            getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager

        val startCal = Calendar.getInstance().apply {
            set(year, month - 1, day, 0, 0, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val endCal = Calendar.getInstance().apply {
            set(year, month - 1, day, 23, 59, 59)
            set(Calendar.MILLISECOND, 999)
        }

        val stats = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startCal.timeInMillis,
            endCal.timeInMillis
        )

        var totalMinutes = 0L
        var lateNightMinutes = 0L

        // Late night = between 22:00 and 05:00
        val lateNightStart = Calendar.getInstance().apply {
            set(year, month - 1, day, 22, 0, 0)
        }
        val lateNightEnd = Calendar.getInstance().apply {
            set(year, month - 1, day + 1, 5, 0, 0)
        }

        for (stat in stats) {
            val foregroundTime = stat.totalTimeInForeground / 60000 // to minutes
            totalMinutes += foregroundTime

            // Rough estimate of late night usage based on last time used
            if (stat.lastTimeUsed >= lateNightStart.timeInMillis ||
                stat.lastTimeUsed <= lateNightEnd.timeInMillis
            ) {
                lateNightMinutes += foregroundTime / 4 // approximate
            }
        }

        return mapOf(
            "totalMinutes" to totalMinutes.toInt(),
            "lateNightMinutes" to lateNightMinutes.toInt()
        )
    }
}
