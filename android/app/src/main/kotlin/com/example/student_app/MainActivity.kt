package com.example.student_app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    private val CHANNEL = "device_id_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.e("DEBUG_MAIN", "MainActivity onCreate() CALLED")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {

        Log.e("DEBUG_MAIN", "configureFlutterEngine() CALLED")

        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            Log.e("DEBUG_MAIN", "Method called: ${call.method}")

            when (call.method) {

                // ✅ OLD: Device ID
                "getDeviceUniqueId" -> {

                    val androidId = Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ANDROID_ID
                    )

                    Log.e("DEBUG_MAIN", "ANDROID_ID READ: $androidId")

                    result.success(androidId)
                }

                // ✅ NEW: Open File / URL
                "openFileOrUrl" -> {

                    val path = call.argument<String>("path")

                    if (path == null) {
                        result.error("NULL_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }

                    Log.e("DEBUG_MAIN", "Opening: $path")

                    try {

                        val intent = Intent(Intent.ACTION_VIEW)

                        if (path.startsWith("http")) {

                            // 🌐 Open URL
                            intent.data = Uri.parse(path)

                        } else {

                            // 📁 Open Local File
                            val file = File(path)

                            val uri = FileProvider.getUriForFile(
                                this,
                                "$packageName.provider",
                                file
                            )

                            intent.setDataAndType(uri, "*/*")
                            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }

                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

                        startActivity(intent)

                        result.success(true)

                    } catch (e: Exception) {

                        Log.e("DEBUG_MAIN", "Open error", e)

                        result.error("OPEN_FAILED", e.message, null)
                    }
                }

                else -> {

                    Log.e("DEBUG_MAIN", "Method NOT implemented: ${call.method}")

                    result.notImplemented()
                }
            }
        }
    }
}
