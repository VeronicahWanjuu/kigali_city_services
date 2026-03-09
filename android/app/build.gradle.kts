plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"
}

android {
    namespace "com.kigali.kigali_directory"
    compileSdk 35
💡 compileSdk 35 required for Android 15 compatibility — changed from 34 in original plan.

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId "com.kigali.kigali_directory"
        minSdk 23
💡 minSdk raised to 23 because geolocator 13.x requires minimum API level 23.
        targetSdk 35
        versionCode flutter.versionCode
        versionName flutter.versionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.10"
    implementation "androidx.multidex:multidex:2.0.1"
}
