package com.hopeos.hopeos

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

/**
 * Android Foreground Service that keeps HopeOS alive in the background.
 *
 * Displays a persistent notification with quick-capture action buttons
 * (Note, Mood, Drink, Expense, Income) accessible from the notification
 * shade and lock screen.
 *
 * The service survives app task removal and restarts automatically
 * after device reboot (via [BootReceiver]).
 */
class QuickCaptureService : Service() {

    companion object {
        const val CHANNEL_ID = "hopeos_foreground"
        const val NOTIFICATION_ID = 2001
        const val ACTION_STOP = "com.hopeos.ACTION_STOP_SERVICE"
        const val EXTRA_QUICK_ACTION = "quick_action"
        const val ACTION_NOTE = "quick_note"
        const val ACTION_MOOD = "quick_mood"
        const val ACTION_DRINK = "quick_drink"

        fun start(context: Context) {
            val intent = Intent(context, QuickCaptureService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(intent)
            } else {
                context.startService(intent)
            }
        }

        fun stop(context: Context) {
            context.stopService(Intent(context, QuickCaptureService::class.java))
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }

        val notification = buildNotification()
        startForeground(NOTIFICATION_ID, notification)

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onTaskRemoved(rootIntent: Intent?) {
        // Restart service if the user swipes away the app
        super.onTaskRemoved(rootIntent)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "HopeOS Quick Capture",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Persistent notification with quick capture buttons"
                setShowBadge(false)
                setSound(null, null)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(): Notification {
        // Tapping the notification body opens the app
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPending = PendingIntent.getActivity(
            this, 0, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Quick action buttons that open the app with a specific action extra
        val notePending = buildActionPendingIntent(ACTION_NOTE, 3001)
        val moodPending = buildActionPendingIntent(ACTION_MOOD, 3002)
        val drinkPending = buildActionPendingIntent(ACTION_DRINK, 3003)

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("HopeOS")
            .setContentText("Quick log actions")
            .setSmallIcon(android.R.drawable.ic_menu_edit)
            .setOngoing(true)
            .setShowWhen(false)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setContentIntent(openPending)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .addAction(0, "\uD83D\uDCDD Note", notePending)
            .addAction(0, "\uD83D\uDE0A Mood", moodPending)
            .addAction(0, "\uD83D\uDCA7 Drink", drinkPending)
            .build()
    }

    private fun buildActionPendingIntent(action: String, requestCode: Int): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            this.action = "com.hopeos.QUICK_ACTION"
            putExtra(EXTRA_QUICK_ACTION, action)
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        return PendingIntent.getActivity(
            this, requestCode, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
}
