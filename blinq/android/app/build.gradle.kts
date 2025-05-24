// android/app/build.gradle.kts

import org.gradle.api.JavaVersion

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Nome do pacote deve corresponder ao `package_name` em google-services.json
    namespace = "com.example.blinq"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.blinq"
        // Aumentado para atender ao requisito do Firebase Auth (minSdkVersion 23)
        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        versionCode = 1  // ajuste conforme seu pubspec.yaml
        versionName = "1.0.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("debug") {
            isMinifyEnabled = false
            isDebuggable = true
        }
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}