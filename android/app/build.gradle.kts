plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.laratik.schools"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion intentionally unset: none of the project plugins ship native C/C++ code,
    // so the default `flutter.ndkVersion` reference would force-sideload a ~1GB NDK
    // package on first build. Uncomment if a future plugin needs it.

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // -------------------------------------------------------------------------
    // Flavor matrix.
    //
    // Mirrors lib/config/flavor_config.dart. When the Dart-side registry adds a
    // new AppConfig entry, add a matching productFlavor here so the build
    // produces a side-by-side installable APK (unique applicationId, its own
    // launcher label, and its own versionName suffix).
    //
    // The base applicationId is "io.laratik.schools" (production). Each
    // non-prod flavor appends a suffix so dev / local / qa installs coexist
    // on a single device.
    //
    // To build a specific flavor:
    //   flutter run --dart-define=APP_FLAVOR=dev   -t lib/main.dart
    //   flutter build apk --dart-define=APP_FLAVOR=qa
    //   flutter build appbundle --dart-define=APP_FLAVOR=prod
    // -------------------------------------------------------------------------
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "Laratik Schools (Dev)")
        }
        create("local") {
            dimension = "environment"
            applicationIdSuffix = ".local"
            versionNameSuffix = "-local"
            resValue("string", "app_name", "Laratik Schools (Local)")
        }
        create("qa") {
            dimension = "environment"
            applicationIdSuffix = ".qa"
            versionNameSuffix = "-qa"
            resValue("string", "app_name", "Laratik Schools (QA)")
        }
        create("prod") {
            dimension = "environment"
            // No applicationIdSuffix: prod owns the bare applicationId so
            // its install can't coexist with another flavor on the same
            // device (intentional — only one production install allowed).
            resValue("string", "app_name", "Laratik Schools")
        }
    }

    defaultConfig {
        applicationId = "io.laratik.schools"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
