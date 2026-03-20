plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "nkiem.com.chotet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "nkiem.com.chotet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Load environment variables from .env file
        val envFile = project.rootProject.file("../.env")
        val envProperties = java.util.Properties()
        if (envFile.exists()) {
            envFile.inputStream().use { envProperties.load(it) }
        }

        resValue("string", "facebook_app_id", envProperties.getProperty("FACEBOOK_APP_ID") ?: "")
        resValue("string", "facebook_client_token", envProperties.getProperty("FACEBOOK_CLIENT_TOKEN") ?: "")
        resValue("string", "fb_login_protocol_scheme", envProperties.getProperty("FB_LOGIN_PROTOCOL_SCHEME") ?: "")
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
