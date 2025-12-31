import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. 👇 LOAD LOCAL PROPERTIES (If they exist)
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

    // 2. 👇 CLOUD INJECTION (App Name & ID)
    val cloudAppName = System.getenv("CLOUD_APP_NAME") ?: "Student Smart Pay"
    val cloudAppId = System.getenv("CLOUD_APP_ID") ?: "com.example.student_card_app"

    defaultConfig {
        applicationId = cloudAppId
        minSdk = 27
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Inject Name into Manifest
        manifestPlaceholders["appName"] = cloudAppName
    }

    // 3. 👇 DYNAMIC SIGNING CONFIG (The "Switch")
    signingConfigs {
        create("release") {
            // OPTION A: Look for Cloud Environment Variables first
            val envStorePath = System.getenv("KEYSTORE_PATH")
            val envStorePass = System.getenv("KEYSTORE_PASSWORD")
            val envKeyAlias = System.getenv("KEY_ALIAS")
            val envKeyPass = System.getenv("KEY_PASSWORD")

            // OPTION B: Look for Local `key.properties`
            val localStoreFile = keystoreProperties["storeFile"] as String?
            val localStorePass = keystoreProperties["storePassword"] as String?
            val localKeyAlias = keystoreProperties["keyAlias"] as String?
            val localKeyPass = keystoreProperties["keyPassword"] as String?

            if (envStorePath != null && File(envStorePath).exists()) {
                println("✅ CI/CD: Signing with Injected Cloud Key.")
                storeFile = File(envStorePath)
                storePassword = envStorePass
                keyAlias = envKeyAlias
                keyPassword = envKeyPass
            } else if (localStoreFile != null && File(localStoreFile).exists()) {
                println("✅ LOCAL: Signing with key.properties.")
                storeFile = File(localStoreFile)
                storePassword = localStorePass
                keyAlias = localKeyAlias
                keyPassword = localKeyPass
            } else {
                println("⚠️ WARNING: No signing keys found. Release build will fail or be unsigned.")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            matchingFallbacks += listOf("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    val room_version = "2.6.1"
    implementation("androidx.room:room-runtime:$room_version")

    // 👇 SMART SDK INJECTION
    val envAarPath = System.getenv("AAR_PATH")
    val localAarPath = "libs/card-emulator-release.aar"

    if (envAarPath != null && File(envAarPath).exists()) {
        // SCENARIO 1: CLOUD BUILD (Injected from Secret)
        println("✅ CI/CD: Using Injected SDK at $envAarPath")
        implementation(files(envAarPath))
    } else if (file(localAarPath).exists()) {
        // SCENARIO 2: LOCAL DEV (File exists on your laptop)
        println("✅ LOCAL: Using SDK at $localAarPath")
        implementation(files(localAarPath))
    } else {
        // SCENARIO 3: MISSING FILE (Prevent Build Failure)
        val msg = "❌ CRITICAL ERROR: Card Emulator SDK not found!\n" +
                "   - Local: 'libs/card-emulator-release.aar' is missing.\n" +
                "   - Cloud: 'AAR_PATH' env var is missing.\n" +
                "   Build cannot proceed."
        // We throw an exception to stop the build immediately so you know why it failed.
        throw GradleException(msg)
    }
}