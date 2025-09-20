# Build stage
FROM gradle:9.1.0-jdk-21-and-24-graal AS build
WORKDIR /workspace/app

# Copy build files
COPY build.gradle.kts settings.gradle.kts gradlew ./
COPY gradle gradle

# Download dependencies
RUN gradle dependencies --no-daemon

# Copy source code
COPY src src

# Build the application with reduced memory usage
RUN gradle clean nativeCompile --no-daemon

# Production stage
FROM alpine:latest
WORKDIR /app

# Install necessary runtime dependencies for native Spring Boot apps
RUN apk add --no-cache \
    libstdc++ \
    gcompat \
    libc6-compat \
    libgcc

# Create non-root user
RUN addgroup -S spring && adduser -S spring -G spring

# Copy native application and dependencies
COPY --from=build /workspace/app/build/native/nativeCompile/spring-app /app/spring-app

# Make executable
RUN chmod +x /app/spring-app

USER spring:spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Entrypoint
ENTRYPOINT ["/app/spring-app"]
