package com.example.actibind

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

private const val PREFS = "actibind_widgets"

object ActiBindWidgetUpdater {
    fun update(context: Context, values: Map<String, Any?>) {
        val preferences = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        preferences.edit().apply {
            values.forEach { (key, value) ->
                when (value) {
                    is Number -> putInt(key, value.toInt())
                    is String -> putString(key, value)
                }
            }
        }.apply()
        TodoWidgetProvider.refresh(context)
        NextActivityWidgetProvider.refresh(context)
        DailyInsightWidgetProvider.refresh(context)
    }

    fun launchIntent(context: Context): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(context, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        return PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }
}

class TodoWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) =
        update(context, manager, ids)

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            update(context, manager, manager.getAppWidgetIds(ComponentName(context, TodoWidgetProvider::class.java)))
        }

        private fun update(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            val count = prefs.getInt("todo_count", 0)
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_todo).apply {
                    setTextViewText(R.id.todo_title, if (count == 1) "1 open task" else "$count open tasks")
                    setTextViewText(R.id.todo_items, prefs.getString("todo_items", "Open ActiBind to sync tasks"))
                    setOnClickPendingIntent(R.id.widget_root, ActiBindWidgetUpdater.launchIntent(context))
                }
                manager.updateAppWidget(id, views)
            }
        }
    }
}

class NextActivityWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) =
        update(context, manager, ids)

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            update(context, manager, manager.getAppWidgetIds(ComponentName(context, NextActivityWidgetProvider::class.java)))
        }

        private fun update(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_next_activity).apply {
                    setTextViewText(R.id.activity_name, prefs.getString("activity_name", "Open ActiBind to sync"))
                    setTextViewText(R.id.activity_time, prefs.getString("activity_time", "Planner"))
                    setTextViewText(R.id.activity_category, prefs.getString("activity_category", "Next activity"))
                    setOnClickPendingIntent(R.id.widget_root, ActiBindWidgetUpdater.launchIntent(context))
                }
                manager.updateAppWidget(id, views)
            }
        }
    }
}

class DailyInsightWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) =
        update(context, manager, ids)

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            update(context, manager, manager.getAppWidgetIds(ComponentName(context, DailyInsightWidgetProvider::class.java)))
        }

        private fun update(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            ids.forEach { id ->
                val views = RemoteViews(context.packageName, R.layout.widget_daily_insight).apply {
                    setTextViewText(R.id.insight_text, prefs.getString("insight", "Generate an insight in ActiBind to see it here."))
                    setTextViewText(R.id.insight_updated, prefs.getString("insight_updated", "No insight synced yet"))
                    setOnClickPendingIntent(R.id.widget_root, ActiBindWidgetUpdater.launchIntent(context))
                }
                manager.updateAppWidget(id, views)
            }
        }
    }
}
