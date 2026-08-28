group = "com.learntoflutter.flutter_embed_unity"
version = "1.0-SNAPSHOT"

buildscript {
    val kotlinVersion = "1.8.22"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
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
    id("kotlin-android")
}

android {
    namespace = "com.learntoflutter.flutter_embed_unity_android"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11
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
        minSdk = 22
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

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
    // This is to include the .jar file in the libs folder containing Unity classes required
    // to compile the plugin (because for example we extend com.unity3d.player.UnityPlayer)
    // The .jar file is taken from the currently supported Unity Editor files: for Unity 2022.3
    // LTS on Windows this can be found at:
    // <Unity hub editors install folder>\2022.3.7f1\Editor\Data\PlaybackEngines\AndroidPlayer\Variations\mono\Development\Classes
    // Use compileOnly because we only need this to compile the plugin during development - at
    // runtime this dependency will be provided by the user's exported Unity project
    compileOnly(fileTree("libs") {
        include("*.jar")
    })
}