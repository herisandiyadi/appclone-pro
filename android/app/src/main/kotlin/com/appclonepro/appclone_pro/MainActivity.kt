package com.appclonepro.appclone_pro

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Native bridge: exposes PackageManager (real installed apps) and
/// real app launching via launch intents to the Flutter side.
class MainActivity : FlutterActivity() {

    private val channelName = "appclone_pro/native"
    private lateinit var containerManager: VirtualContainerManager

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        containerManager = VirtualContainerManager(applicationContext)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> handleGetInstalledApps(result)
                    "launchApp" -> handleLaunchApp(call, result)
                    "getContainerStorage" -> handleGetContainerStorage(call, result)
                    "clearContainer" -> handleClearContainer(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    /// Returns launchable, real installed apps (excluding this app itself).
    private fun handleGetInstalledApps(result: MethodChannel.Result) {
        try {
            val pm = packageManager
            val launcherIntent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
            val resolveInfos = pm.queryIntentActivities(launcherIntent, 0)
            val apps = mutableListOf<Map<String, Any>>()
            for (ri in resolveInfos) {
                val pkg = ri.activityInfo?.packageName ?: continue
                if (pkg == packageName) continue
                val label = try {
                    ri.loadLabel(pm).toString()
                } catch (e: Exception) {
                    pkg
                }
                apps.add(mapOf("packageName" to pkg, "appName" to label))
            }
            result.success(apps)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }

    /// Returns the real storage bytes used by a virtual container on disk.
    private fun handleGetContainerStorage(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val cloneId = call.argument<String>("cloneId")
        if (cloneId == null) {
            result.error("BAD_ARGS", "cloneId is required", null)
            return
        }
        try {
            val bytes = containerManager.calculateStorageBytes(cloneId)
            result.success(bytes)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }

    /// Clears a virtual container's data directories.
    private fun handleClearContainer(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val cloneId = call.argument<String>("cloneId")
        if (cloneId == null) {
            result.error("BAD_ARGS", "cloneId is required", null)
            return
        }
        try {
            val cleared = containerManager.clearContainer(cloneId)
            result.success(cleared)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }

    /// Opens the real installed app via its launch intent.
    /// Returns true when launched, false when the app is not installed.
    private fun handleLaunchApp(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        val pkg = call.argument<String>("packageName")
        if (pkg == null) {
            result.error("BAD_ARGS", "packageName is required", null)
            return
        }
        try {
            val intent = packageManager.getLaunchIntentForPackage(pkg)
            if (intent == null) {
                result.success(false)
            } else {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                result.success(true)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }
}
