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
}

// Some plugins (file_picker...) are compiled against an older SDK: force compileSdk 36.
subprojects {
    fun forceSdk(p: Project) {
        val ext = p.extensions.findByName("android") ?: return
        val attempts = listOf<() -> Unit>(
            { ext.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java).invoke(ext, 36) },
            { ext.javaClass.getMethod("compileSdkVersion", Int::class.javaPrimitiveType).invoke(ext, 36) },
        )
        for (attempt in attempts) {
            try {
                attempt()
                return
            } catch (e: Exception) {
                // try the next way
            }
        }
        println("compileSdk override skipped for ${p.name}")
    }
    if (project.name != "app") {
        if (project.state.executed) forceSdk(project) else project.afterEvaluate { forceSdk(project) }
    }
}

// The lint "vital" check crashes on this build machine (Java/lint mismatch): turn it off.
subprojects {
    tasks.configureEach {
        if (name.startsWith("lintVital")) {
            enabled = false
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}