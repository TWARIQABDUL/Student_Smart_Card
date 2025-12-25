import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. 👇 LOAD THE KEY PROPERTIES
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.example.student_card_app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.student_card_app"
        minSdk = 27
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 2. 👇 DEFINE THE SIGNING CONFIGURATION
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            // 3. 👇 USE THE RELEASE KEY (Not Debug!)
            signingConfig = signingConfigs.getByName("release")

            // Optional: If you enable this, ensure SDK classes have @Keep annotations
            var minifyEnabled = true
            var shrinkResources = true
        }
        debug {
            // Fallback to allow using the Release AAR in Debug mode
            matchingFallbacks += listOf("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    val room_version = "2.6.1"
    implementation ("androidx.room:room-runtime:$room_version")

    // Your SDK
    implementation(files("libs/card-emulator-release.aar"))
}