package com.appsimple.analytics

import android.os.Bundle
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.analytics.FirebaseAnalytics
import org.godotengine.godot.Dictionary
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

class FirebaseAnalyticsBridge(godot: Godot) : GodotPlugin(godot) {
    private var analytics: FirebaseAnalytics? = null

    override fun getPluginName() = "FirebaseAnalyticsBridge"

    @UsedByGodot
    fun configure(apiKey: String, applicationId: String, projectId: String, senderId: String): Boolean {
        val appContext = context ?: return false
        if (apiKey.isBlank() || applicationId.isBlank() || projectId.isBlank()) return false
        return try {
            if (FirebaseApp.getApps(appContext).isEmpty()) {
                val builder = FirebaseOptions.Builder()
                    .setApiKey(apiKey)
                    .setApplicationId(applicationId)
                    .setProjectId(projectId)
                if (senderId.isNotBlank()) builder.setGcmSenderId(senderId)
                FirebaseApp.initializeApp(appContext, builder.build())
            }
            analytics = FirebaseAnalytics.getInstance(appContext)
            true
        } catch (_: IllegalStateException) {
            false
        } catch (_: IllegalArgumentException) {
            false
        }
    }

    @UsedByGodot
    fun set_collection_enabled(enabled: Boolean) {
        getAnalytics()?.setAnalyticsCollectionEnabled(enabled)
    }

    @UsedByGodot
    fun log_event(eventName: String, parameters: Dictionary) {
        val bundle = Bundle()
        parameters.forEach { (rawKey, value) ->
            val key = rawKey.toString()
            when (value) {
                is Boolean -> bundle.putLong(key, if (value) 1L else 0L)
                is Byte, is Short, is Int, is Long -> bundle.putLong(key, (value as Number).toLong())
                is Float, is Double -> bundle.putDouble(key, (value as Number).toDouble())
                else -> bundle.putString(key, value?.toString().orEmpty().take(100))
            }
        }
        getAnalytics()?.logEvent(eventName.take(40), bundle)
    }

    private fun getAnalytics(): FirebaseAnalytics? {
        analytics?.let { return it }
        val appContext = context ?: return null
        return try {
            if (FirebaseApp.getApps(appContext).isEmpty()) {
                FirebaseApp.initializeApp(appContext) ?: return null
            }
            FirebaseAnalytics.getInstance(appContext).also { analytics = it }
        } catch (_: IllegalStateException) {
            null
        }
    }
}
