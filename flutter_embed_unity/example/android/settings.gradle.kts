pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // This is the AGP (Android Gradle Plugin) version.
    // The version of Gradle is specified in gradle-wrapper.properties.
    id("com.android.application") version "9.1.0" apply false
    // This is the Kotlin Gradle Plugin version
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
}

include(":app")
include(":unityLibrary")
include(":unityLibrary:xrmanifest.androidlib")