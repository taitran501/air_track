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

    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = JavaVersion.VERSION_11.toString()
        targetCompatibility = JavaVersion.VERSION_11.toString()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}

rootProject.layout.buildDirectory.set(file("../build/android"))
subprojects {
    project.layout.buildDirectory.set(file("${rootProject.layout.buildDirectory.asFile.get()}/${project.name}"))
    project.evaluationDependsOn(":app")
}

tasks.named("clean", Delete::class) {
    delete(rootProject.layout.buildDirectory)
}
