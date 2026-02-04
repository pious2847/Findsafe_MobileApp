package com.example.findsafe

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * MainActivity for FindSafe app
 * Handles device admin features through platform channels
 */
class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.findsafe/device_admin"
    private val TAG = "FindSafeMainActivity"
    private val DEVICE_ADMIN_REQUEST_CODE = 1

    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var componentName: ComponentName

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize device policy manager
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        componentName = ComponentName(this, DeviceAdminReceiver::class.java)

        // Check if device admin is active
        if (!devicePolicyManager.isAdminActive(componentName)) {
            Log.i(TAG, "Device admin not active, requesting activation")
        } else {
            Log.i(TAG, "Device admin is active")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Set up method channel for device admin features
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "lockDevice" -> {
                        val message = call.argument<String>("message") ?: "Device locked remotely"
                        val success = lockDevice(message)
                        result.success(success)
                    }
                    "wipeData" -> {
                        val message = call.argument<String>("message") ?: "Device wiped remotely"
                        val success = wipeData(message)
                        result.success(success)
                    }
                    "isDeviceAdminActive" -> {
                        val isActive = devicePolicyManager.isAdminActive(componentName)
                        result.success(isActive)
                    }
                    "requestDeviceAdmin" -> {
                        requestDeviceAdmin()
                        result.success(true)
                    }
                    else -> {
                        Log.w(TAG, "Method not implemented: ${call.method}")
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error handling method call: ${call.method}", e)
                result.error("PLATFORM_ERROR", e.message, e.stackTraceToString())
            }
        }
    }

    private fun lockDevice(message: String): Boolean {
        Log.i(TAG, "Attempting to lock device: $message")

        if (devicePolicyManager.isAdminActive(componentName)) {
            try {
                // Lock the device
                devicePolicyManager.lockNow()
                Toast.makeText(this, message, Toast.LENGTH_LONG).show()
                Log.i(TAG, "Device locked successfully")
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to lock device", e)
                Toast.makeText(this, "Failed to lock device: ${e.message}", Toast.LENGTH_LONG).show()
                return false
            }
        } else {
            Log.w(TAG, "Cannot lock device: Device admin not active")
            // Request device admin privileges
            requestDeviceAdmin()
            return false
        }
    }

    private fun wipeData(message: String): Boolean {
        Log.i(TAG, "Attempting to wipe device: $message")

        if (devicePolicyManager.isAdminActive(componentName)) {
            try {
                // Show a warning toast before wiping
                Toast.makeText(this, message, Toast.LENGTH_LONG).show()

                // In a real app, you would want to add additional confirmation steps
                // and security measures before wiping the device

                // This is commented out for safety, as it would actually wipe the device
                // The flags parameter can include WIPE_EXTERNAL_STORAGE to also wipe SD card
                // devicePolicyManager.wipeData(DevicePolicyManager.WIPE_EXTERNAL_STORAGE)

                Log.i(TAG, "Device wipe command received (simulation only)")
                return true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to wipe device", e)
                Toast.makeText(this, "Failed to wipe device: ${e.message}", Toast.LENGTH_LONG).show()
                return false
            }
        } else {
            Log.w(TAG, "Cannot wipe device: Device admin not active")
            // Request device admin privileges
            requestDeviceAdmin()
            return false
        }
    }

    private fun requestDeviceAdmin() {
        Log.i(TAG, "Requesting device admin privileges")

        try {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
            intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "Device admin privileges are required for FindSafe security features like remote locking and data protection")
            startActivityForResult(intent, DEVICE_ADMIN_REQUEST_CODE)
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting device admin", e)
            Toast.makeText(this, "Failed to request device admin: ${e.message}", Toast.LENGTH_LONG).show()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == DEVICE_ADMIN_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                Log.i(TAG, "Device admin enabled by user")
                Toast.makeText(this, "Security features enabled", Toast.LENGTH_SHORT).show()
            } else {
                Log.w(TAG, "Device admin rejected by user")
                Toast.makeText(this, "Security features not enabled", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
