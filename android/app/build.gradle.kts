plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.digital_inventory"
    compileSdk = flutter.compileSdkVersion

    ndkVersion = "25.1.8937393"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.digital_inventory"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-manifest-config
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Left empty and clean since we are focusing on pure frontend layouts for now
}
// Add this at the very bottom of android/app/build.gradle.kts
tasks.whenTaskAdded {
    if (name.startsWith("compile") && name.contains("Ndk")) {
        enabled = false
    }
}