import java.util.Properties

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.digital_inventory" // Matches your package namespace
    compileSdk = flutter.compileSdkVersion
    // jni (a transitive dep of google_mlkit_text_recognition) requires a newer
    // NDK than the Flutter default; without pinning this, Gradle just warns
    // and silently uses the older NDK, which the plugin isn't actually built for.
    ndkVersion = "28.2.13676358"

    compileOptions {
        // 🛠️ CRITICAL FIX: Enables Java 8+ API desugaring for local notifications package
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.digital_inventory"
        minSdk = flutter.minSdkVersion // Required baseline for modern plugin support
        targetSdk = flutter.targetSdkVersion
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🛠️ CRITICAL FIX: The required library dependency engine to perform core Java desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
