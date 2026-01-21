# Build stage con Amazon Corretto JDK 25
FROM amazoncorretto:25.0.2-alpine3.22 AS build

# Instalar Gradle y dependencias necesarias
RUN apk add --no-cache wget unzip
RUN wget https://services.gradle.org/distributions/gradle-9.2.1-bin.zip \
    && unzip gradle-9.2.1-bin.zip \
    && mv gradle-9.2.1 /opt/gradle \
    && rm gradle-9.2.1-bin.zip

# JDK 25 environment variables for optimal performance
ENV JAVA_OPTS="-XX:+UseCompactObjectHeaders -XX:+UseContainerSupport" \
    SPRING_PROFILES_ACTIVE=prod

WORKDIR /workspace/app

# JDK 25 environment variables for optimal performance
ENV GRADLE_OPTS="-Dorg.gradle.daemon=false -Xmx2g" \
    PATH="/opt/gradle/bin:${PATH}"

# Copy build files
COPY build.gradle.kts settings.gradle.kts gradlew ./
COPY gradle gradle

# Download dependencies
RUN gradle dependencies --no-daemon

# Copy source code
COPY src src

# Build the application JAR
RUN gradle clean bootJar --no-daemon

# Production stage
FROM amazoncorretto:25.0.0-alpine3.22-jre
WORKDIR /app

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring

# Copy JAR file
COPY --from=build /workspace/app/build/libs/*.jar /app/spring-app.jar

# Change ownership
RUN chown spring:spring /app/spring-app.jar

USER spring:spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Entrypoint with JDK 25 optimizations
ENTRYPOINT ["java",
    # JDK 25 Compact Object Headers (8-byte headers instead of 12-byte)
    "-XX:+UseCompactObjectHeaders",
    # Memory optimizations for containers
    "-XX:+UseContainerSupport",
    "-XX:MaxRAMPercentage=80.0",
    # Garbage collection optimizations
    "-XX:+UseG1GC",
    "-XX:MaxGCPauseMillis=200",
    # JIT compiler optimizations
    "-XX:+UseStringDeduplication",
    "-XX:+OptimizeStringConcat",
    # JDK 25 performance improvements
    "-XX:+EnableDynamicAgentLoading",
    # Application JAR
    "-jar", "/app/spring-app.jar"]
