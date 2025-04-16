plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bringo"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.bringo"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // Enable minification
            shrinkResources = true  // Enable resource shrinking

            // Proguard rules file
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"), 
                "proguard-rules.pro"
            )
        }
    }

    dependencies {
    implementation("com.android.support:appcompat-v7:28.0.0") // Example dependency, add other dependencies here classpath("com.android.tools.build:gradle:7.4.0")  // AGP version for Gradle 8.x
    // Add other dependencies as needed
    }

}

flutter {
    source = "../.."
}
