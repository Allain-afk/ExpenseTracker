package com.example.offline_expense_tracker

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class ExpenseTrackerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val views = RemoteViews(context.packageName, R.layout.expense_tracker_widget)

        // Create intent to open the app when widget is tapped
        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 
            0, 
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Set the pending intent on the entire widget
        views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

        // Update balance
        val balance = widgetData.getString("balance", "₱0.00") ?: "₱0.00"
        views.setTextViewText(R.id.widget_balance, balance)

        // Update income
        val income = widgetData.getString("total_income", "₱0.00") ?: "₱0.00"
        views.setTextViewText(R.id.widget_income, income)

        // Update expense
        val expense = widgetData.getString("total_expense", "₱0.00") ?: "₱0.00"
        views.setTextViewText(R.id.widget_expense, expense)

        // Update recent transactions
        for (i in 0..2) {
            val description = widgetData.getString("transaction_${i}_description", "") ?: ""
            val amount = widgetData.getString("transaction_${i}_amount", "") ?: ""
            val type = widgetData.getString("transaction_${i}_type", "") ?: ""

            when (i) {
                0 -> {
                    if (description.isNotEmpty()) {
                        views.setTextViewText(R.id.transaction_1_description, description)
                        views.setTextViewText(R.id.transaction_1_amount, amount)
                        views.setTextColor(R.id.transaction_1_amount, 
                            if (type == "income") 0xFF4CAF50.toInt() else 0xFFF44336.toInt())
                        views.setViewVisibility(R.id.transaction_1_layout, android.view.View.VISIBLE)
                    } else {
                        views.setViewVisibility(R.id.transaction_1_layout, android.view.View.GONE)
                    }
                }
                1 -> {
                    if (description.isNotEmpty()) {
                        views.setTextViewText(R.id.transaction_2_description, description)
                        views.setTextViewText(R.id.transaction_2_amount, amount)
                        views.setTextColor(R.id.transaction_2_amount, 
                            if (type == "income") 0xFF4CAF50.toInt() else 0xFFF44336.toInt())
                        views.setViewVisibility(R.id.transaction_2_layout, android.view.View.VISIBLE)
                    } else {
                        views.setViewVisibility(R.id.transaction_2_layout, android.view.View.GONE)
                    }
                }
            }
        }

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
} 