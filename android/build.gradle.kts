allprojects {
    repositories {
        google()
        mavenCentral()
        // Add the repository for background_fetch plugin
        maven {
            url = uri("https://dl.bintray.com/transistorsoft/maven")
        }
        maven {
            url = uri("https://jitpack.io")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
