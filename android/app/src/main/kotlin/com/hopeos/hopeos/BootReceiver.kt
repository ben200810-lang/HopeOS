package com.hopeos.hopeos

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences

/**
 * Restarts [QuickCaptureService] after device reboot if the user
 * had the foreground service enabled before the reboot.
 */
class BootReceiver : BroadcastReceiver() {

    companion object {
        private const val PREFS_NAME = "hopeos_service_prefs"
        private const val KEY_SERVICE_ENABLED = "foreground_service_enabled"

        fun setServiceEnabled(context: Context, enabled: Boolean) {
            prefs(context).edit().putBoolean(KEY_SERVICE_ENABLED, enabled).apply()
        }

        fun isServiceEnabled(context: Context): Boolean {
            return prefs(context).getBoolean(KEY_SERVICE_ENABLED, false)
        }

        private fun prefs(context: Context): SharedPreferences {
            return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON" ||
            intent.action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            if (isServiceEnabled(context)) {
                QuickCaptureService.start(context)
            }
        }
    }
}
