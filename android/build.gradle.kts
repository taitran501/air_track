buildscript {
    // Thêm repositories vào buildscript
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0")
        classpath("com.google.gms:google-services:4.3.10")
    }
}

allprojects {
  repositories {
    google()
    mavenCentral()
  }

  tasks.withType(JavaCompile).configureEach {
    javaCompiler = javaToolchains.compilerFor {
      languageVersion = JavaLanguageVersion.of(8)
    }
  }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
