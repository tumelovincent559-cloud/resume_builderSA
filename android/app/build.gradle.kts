android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.cv_builder"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildToolsVersion = "34.0.0"

    ndkVersion = "27.0.12077973" // ✅ set NDK version here

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}
