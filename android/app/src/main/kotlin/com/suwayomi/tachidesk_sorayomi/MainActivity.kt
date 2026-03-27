package com.suwayomi.tachidesk_sorayomi

import io.flutter.embedding.android.FlutterFragmentActivity
import android.view.KeyEvent
import dev.darttools.flutter_android_volume_keydown.FlutterAndroidVolumeKeydownPlugin.eventSink

class MainActivity: FlutterFragmentActivity() {
    override fun onKeyDown(keyCode: Int, event: KeyEvent): Boolean {
        if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN && eventSink != null) {
            eventSink.success(true)
            return true
        }
        if (keyCode == KeyEvent.KEYCODE_VOLUME_UP && eventSink != null) {
            eventSink.success(false)
            return true
        }
        return super.onKeyDown(keyCode, event)
    }
}
