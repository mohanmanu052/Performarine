package com.performarine.performarine

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

   /* @Override
    fun onStartCommand => intentAction: UPDATE_NOTIFICATION*/
                /*(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand called")
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this,
            0, notificationIntent, 0
        )
        val notification: Notification = Builder(this, CHANNEL_ID)
            .setContentTitle("Service is Running")
            .setContentText("Listening for Screen Off/On events")
            .setSmallIcon(R.drawable.ic_wallpaper_black_24dp)
            .setContentIntent(pendingIntent)
            .setColor(getResources().getColor(R.color.colorPrimary))
            .build()
        startForeground(1, notification)
        return START_STICKY
    }*/
}
