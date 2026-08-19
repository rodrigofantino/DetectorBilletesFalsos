plugins {
    id("com.android.library") version "8.13.2"
    id("org.jetbrains.kotlin.android") version "2.2.21"
}

layout.buildDirectory.set(file("../../../.local-build/FirebaseAnalyticsBridge"))

android {
    namespace = "com.appsimple.analytics"
    compileSdk = 36
    defaultConfig {
        minSdk = 24
        setProperty("archivesBaseName", "FirebaseAnalyticsBridge")
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
}

dependencies {
    compileOnly(files("../../android/build/libs/release/godot-lib.template_release.aar"))
    implementation("com.google.firebase:firebase-analytics:23.2.0")
}
