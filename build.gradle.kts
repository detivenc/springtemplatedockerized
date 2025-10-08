plugins {
  alias(libs.plugins.kotlin.jvm)
	alias(libs.plugins.kotlin.spring)
	alias(libs.plugins.spring.boot)
	alias(libs.plugins.kotlin.jpa)
}

group = "com.detivenc.github"
version = "0.0.1-SNAPSHOT"
description = "Spring boot project with paseto"

java {
	toolchain {
		languageVersion = JavaLanguageVersion.of(21)
	}
}

repositories {
	mavenCentral()
}

dependencies {
    implementation(platform(libs.spring.boot.bom))
	implementation(libs.spring.boot.starter.actuator)
	implementation(libs.spring.boot.starter.data.jpa)
	implementation(libs.spring.boot.starter.graphql)
	implementation(libs.spring.boot.starter.validation)
	implementation(libs.spring.boot.starter.web)
	implementation(libs.jackson.module.kotlin)
	implementation(libs.kotlin.reflect)
	runtimeOnly(libs.postgresql)
	testImplementation(libs.spring.boot.starter.test)
	testImplementation(libs.kotlin.test.junit5)
	testImplementation(libs.spring.graphql.test)
	testRuntimeOnly(libs.junit.platform.launcher)
}

kotlin {
	compilerOptions {
		freeCompilerArgs.addAll("-Xjsr305=strict")
	}
}

allOpen {
	annotation("jakarta.persistence.Entity")
	annotation("jakarta.persistence.MappedSuperclass")
	annotation("jakarta.persistence.Embeddable")
}

tasks.withType<Test> {
	useJUnitPlatform()
}
