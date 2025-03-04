plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Đảm bảo plugin này có mặt ở đây
}

android {
    namespace = "com.example.air_track"
    compileSdk = 34
    ndkVersion = "27.2.12479018" // Sửa cú pháp đúng

    defaultConfig {
        applicationId = "com.example.air_track"
        minSdk = 23 // Sửa cú pháp đúng
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility(JavaVersion.VERSION_11)
        targetCompatibility(JavaVersion.VERSION_11)
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            variant.assembleProvider.get().doLast {
                copy {
                    from("${project.layout.buildDirectory.get()}/outputs/apk/${variant.name}/app-${variant.name}.apk")
                    into("${rootProject.projectDir}/../build/app/outputs/flutter-apk")
                    rename { "app-${variant.name}.apk" }
                }
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.9.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-messaging")
}
