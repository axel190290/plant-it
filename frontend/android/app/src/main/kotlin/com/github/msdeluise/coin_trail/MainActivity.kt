package com.github.mdeluise.plantit

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.BatteryManager
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Reads the sensors of the phone for the sensor mode of the app: ambient
 * light, air pressure and the compass, plus the battery temperature.
 */
class MainActivity : FlutterActivity(), SensorEventListener {
    private var lux: Float? = null
    private var pressure: Float? = null
    private var azimuth: Float? = null

    private val sensorManager by lazy {
        getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "plant_it/sensors")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "available" -> result.success(
                        mapOf(
                            "light" to (sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT) != null),
                            "pressure" to (sensorManager.getDefaultSensor(Sensor.TYPE_PRESSURE) != null),
                            "compass" to (sensorManager.getDefaultSensor(Sensor.TYPE_ROTATION_VECTOR) != null),
                        )
                    )
                    "start" -> {
                        start(call.argument<Boolean>("dimScreen") ?: true)
                        result.success(null)
                    }
                    "stop" -> {
                        stop()
                        result.success(null)
                    }
                    "read" -> result.success(
                        mapOf(
                            "lux" to lux?.toDouble(),
                            "pressure" to pressure?.toDouble(),
                            "azimuth" to azimuth?.toDouble(),
                            "batteryTemperature" to batteryTemperature(),
                        )
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun start(dimScreen: Boolean) {
        for (type in listOf(Sensor.TYPE_LIGHT, Sensor.TYPE_PRESSURE, Sensor.TYPE_ROTATION_VECTOR)) {
            sensorManager.getDefaultSensor(type)?.let {
                sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
            }
        }
        // The screen stays on, as dark as possible, so the readings go on
        // without lighting the light sensor
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        if (dimScreen) {
            val params = window.attributes
            params.screenBrightness = 0.01f
            window.attributes = params
        }
    }

    private fun stop() {
        sensorManager.unregisterListener(this)
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        val params = window.attributes
        params.screenBrightness = WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        window.attributes = params
        lux = null
        pressure = null
        azimuth = null
    }

    private fun batteryTemperature(): Double? {
        val intent: Intent? = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val tenths = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
        return if (tenths == null || tenths == Int.MIN_VALUE) null else tenths / 10.0
    }

    override fun onSensorChanged(event: SensorEvent) {
        when (event.sensor.type) {
            Sensor.TYPE_LIGHT -> lux = event.values[0]
            Sensor.TYPE_PRESSURE -> pressure = event.values[0]
            Sensor.TYPE_ROTATION_VECTOR -> {
                val rotation = FloatArray(9)
                SensorManager.getRotationMatrixFromVector(rotation, event.values)
                val orientation = FloatArray(3)
                SensorManager.getOrientation(rotation, orientation)
                azimuth = ((Math.toDegrees(orientation[0].toDouble()) + 360) % 360).toFloat()
            }
        }
    }

    override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {}

    override fun onDestroy() {
        sensorManager.unregisterListener(this)
        super.onDestroy()
    }
}
