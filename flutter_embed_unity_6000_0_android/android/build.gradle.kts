buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}


// ------------------------------------------------------------
// TODO: When the min Flutter SDK for this plugin is bumped to
// >= 3.44 this entire block can be removed
//
// Backwards compatibility for Flutter versions < 3.44 to 
// support apps on AGP versions less than 9: only apply the 
// Kotlin Gradle Plugin if Gradle is < 9
val agpMajor = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION.substringBefore('.').toInt()

if (agpMajor < 9) {
    apply(plugin = "org.jetbrains.kotlin.android")
}
// ------------------------------------------------------------


android {
    namespace = "com.learntoflutter.flutter_embed_unity_android"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 23
        // Add proguard rules for the plugin code, these are needed to prevent
        // the plugin breaking (reflection is used when passing messages between
        // Flutter and Unity). consumerProguardFiles are combined with the consuming
        // app's proguard rules when R8 is run. See
        // https://developer.android.com/studio/projects/android-library#Considerations
        consumerProguardFiles("lib-proguard-rules.txt")
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()

                it.outputs.upToDateWhen { false }

                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}



// ------------------------------------------------------------
// TODO: When the min Flutter SDK for this plugin is bumped to
// >= 3.44 this block should be replaced with:
//
// kotlin {
//     compilerOptions {
//         jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
//     }
// }
//
// Use explicit extension configuration for compatibility with Flutter < 3.44,
// where the Kotlin Gradle plugin may be conditionally applied (e.g. with AGP 9).
project.extensions.configure(org.jetbrains.kotlin.gradle.dsl.KotlinAndroidProjectExtension::class.java) {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
// ------------------------------------------------------------


dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    // This is to include the .jar file in the libs folder containing Unity classes required
    // to compile the plugin (because for example we extend com.unity3d.player.UnityPlayer)
    // The .jar file is taken from the currently supported Unity Editor files: for Unity 6000.0.49
    // LTS on Windows this can be found at:
    // <Unity hub editors install folder>\6000.0.49f1\Editor\Data\PlaybackEngines\AndroidPlayer\Variations\mono\Development\Classes
    // Use compileOnly because we only need this to compile the plugin during development - at
    // runtime this dependency will be provided by the user's exported Unity project
    compileOnly(fileTree("libs") {
        include("*.jar")
    })
}