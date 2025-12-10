plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.student_card_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.student_card_app"
//        minSdk = flutter.minSdkVersion
        minSdk = 26 //this will be changed to 27 after testing
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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

// 1. Tell Gradle to look inside the 'libs' folder for dependencies
repositories {
    flatDir {
        dirs("libs")
    }
}

dependencies {
    // 2. Import the AAR by name (without the path)
    implementation(mapOf("name" to "card-emulator-release", "ext" to "aar"))
}