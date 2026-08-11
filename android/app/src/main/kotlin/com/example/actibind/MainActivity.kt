package com.example.actibind

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterActivity() {
    private val channelName = "com.example.actibind/usage_stats"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasUsageStatsPermission())
                    "openSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    "getUsageStats" -> {
                        val start = call.argument<Number>("start")?.toLong()
                        val end = call.argument<Number>("end")?.toLong()
                        if (start == null || end == null) {
                            result.error("INVALID_RANGE", "A start and end time are required", null)
                        } else if (!hasUsageStatsPermission()) {
                            result.error("PERMISSION_DENIED", "Usage access has not been granted", null)
                        } else {
                            result.success(queryUsageStats(start, end))
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName,
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun queryUsageStats(start: Long, end: Long): List<Map<String, Any?>> {
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val packageManager = applicationContext.packageManager
        val installedLabels = installedAppLabels(packageManager)
        return manager.queryAndAggregateUsageStats(start, end)
            .values
            .asSequence()
            .filter { it.totalTimeInForeground > 0 && it.packageName != packageName }
            .sortedByDescending { it.totalTimeInForeground }
            .map { stats ->
                val label = installedLabels[stats.packageName] ?: try {
                    val info = packageManager.getApplicationInfo(stats.packageName, 0)
                    packageManager.getApplicationLabel(info).toString()
                } catch (_: Exception) {
                    readablePackageName(stats.packageName)
                }
                mapOf(
                    "packageName" to stats.packageName,
                    "appName" to label,
                    "foregroundMs" to stats.totalTimeInForeground,
                    "lastTimeUsed" to stats.lastTimeUsed,
                    "icon" to appIcon(packageManager, stats.packageName),
                )
            }
            .toList()
    }

    private fun launcherAppLabels(packageManager: PackageManager): Map<String, String> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        return packageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL)
            .associate { resolveInfo ->
                resolveInfo.activityInfo.packageName to resolveInfo.loadLabel(packageManager).toString()
            }
    }

    private fun installedAppLabels(packageManager: PackageManager): Map<String, String> {
        @Suppress("DEPRECATION")
        val labels = packageManager.getInstalledApplications(0)
            .associate { applicationInfo ->
                applicationInfo.packageName to packageManager.getApplicationLabel(applicationInfo).toString()
            }
            .toMutableMap()
        // Some managed profiles expose launcher activities without including them in
        // the ordinary installed-application result.
        labels.putAll(launcherAppLabels(packageManager))
        return labels
    }

    private fun readablePackageName(packageName: String): String {
        val ignored = setOf("com", "org", "net", "android", "app", "apps", "mobile", "ph")
        val candidate = packageName.split('.')
            .lastOrNull { part -> part.length > 2 && part.lowercase() !in ignored }
            ?: packageName.substringAfterLast('.')
        return candidate.replaceFirstChar { character ->
            if (character.isLowerCase()) character.titlecase() else character.toString()
        }
    }

    private fun appIcon(packageManager: PackageManager, packageName: String): ByteArray? {
        return try {
            drawableToPng(packageManager.getApplicationIcon(packageName))
        } catch (_: Exception) {
            null
        }
    }

    private fun drawableToPng(drawable: Drawable): ByteArray {
        // Adaptive icons commonly report an invalid intrinsic size. Drawing all
        // icon types onto a fixed canvas also keeps the platform-channel payload small.
        val size = 96
        val bitmap = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888).also { bitmap ->
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
        }
        return ByteArrayOutputStream().use { stream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        }
    }
}
