plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.halogen"
    compileSdk = flutter.compileSdkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    val versionCodeProp = project.findProperty("VERSION_CODE")?.toString()?.toInt() ?: 1
    val versionNameProp = project.findProperty("VERSION_NAME")?.toString() ?: "1.0.0"

    defaultConfig {
        applicationId = "com.example.halogen"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Fix: Use proper setter syntax for these properties
        versionCode = versionCodeProp
        versionName = versionNameProp
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
