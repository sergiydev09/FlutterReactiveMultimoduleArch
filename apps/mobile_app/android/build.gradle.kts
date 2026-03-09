allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Workaround para plugins antiguos de Flutter:
    // 1. Namespace no definido en build.gradle → se extrae del AndroidManifest.xml
    // 2. JVM targets inconsistentes entre Java y Kotlin → se fuerza Java 17
    // afterEvaluate garantiza que se aplica DESPUÉS del build.gradle del plugin.
    afterEvaluate {
        plugins.withType<com.android.build.gradle.LibraryPlugin> {
            val ext = extensions.getByType<com.android.build.gradle.LibraryExtension>()
            if (ext.namespace.isNullOrEmpty()) {
                val manifest = file("${projectDir}/src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val pkg = Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifest.readText())?.groupValues?.get(1)
                    if (pkg != null) {
                        ext.namespace = pkg
                    }
                }
            }
            ext.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
    }

    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
