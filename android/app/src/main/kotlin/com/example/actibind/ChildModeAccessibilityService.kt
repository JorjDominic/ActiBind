package com.example.actibind

import android.accessibilityservice.AccessibilityService
import android.content.Context
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class ChildModeAccessibilityService : AccessibilityService() {
    private var lastBlockedPackage: String? = null
    private var lastBlockedAt = 0L

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val openedPackage = event.packageName?.toString() ?: return
        if (openedPackage == packageName) return

        val preferences = getSharedPreferences("actibind_child_mode", Context.MODE_PRIVATE)
        if (!preferences.getBoolean("personal_mode_active", false)) return
        val restricted = preferences.getStringSet("restricted_packages", emptySet()).orEmpty()
        if (openedPackage !in restricted) return

        val now = System.currentTimeMillis()
        if (lastBlockedPackage == openedPackage && now - lastBlockedAt < 900) return
        lastBlockedPackage = openedPackage
        lastBlockedAt = now

        startActivity(
            packageManager.getLaunchIntentForPackage(packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("blocked_package", openedPackage)
            } ?: return,
        )
        Toast.makeText(this, "This app is restricted in Child Mode", Toast.LENGTH_SHORT).show()
    }

    override fun onInterrupt() = Unit
}
