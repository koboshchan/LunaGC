# ==========================================
# Stage 1: Builder
# ==========================================
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /build

# Install git for injectGitHash task
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    rm -rf /var/lib/apt/lists/*

# Copy Gradle wrapper and configuration first to leverage Docker layer caching
COPY gradlew settings.gradle build.gradle ./
COPY gradle/ ./gradle/

# Ensure gradlew has execute permission and pre-download Gradle distribution
RUN chmod +x gradlew && ./gradlew --version

# Copy dependencies, protocol buffers, and source code
COPY lib/ ./lib/
COPY proto/ ./proto/
COPY src/ ./src/
COPY data/ ./data/
COPY keystore.p12 ./

# Build the Fat JAR (skipping handbook to remove npm requirement)
RUN ./gradlew jar -PskipHandbook=1 --no-daemon && \
    mv LunaGC*.jar LunaGC.jar

# ==========================================
# Stage 2: Runner
# ==========================================
FROM eclipse-temurin:17-jre-jammy AS runner

WORKDIR /app

# Install runtime utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends jq curl && \
    rm -rf /var/lib/apt/lists/*

# Copy compiled JAR from builder stage
COPY --from=builder /build/LunaGC.jar /app/LunaGC.jar

# Setup defaults, logging configuration, and application directories
RUN mkdir -p /app/defaults/data /app/data /app/resources /app/resources/BinOutput /app/resources/ExcelBinOutput /app/plugins /app/logs /app/packets /app/cache /app/src/main/resources
COPY --from=builder /build/data/ /app/defaults/data/
COPY --from=builder /build/keystore.p12 /app/defaults/keystore.p12
COPY --from=builder /build/data/ /app/data/
COPY --from=builder /build/keystore.p12 /app/keystore.p12
COPY --from=builder /build/src/main/resources/logback.xml /app/src/main/resources/logback.xml

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Ports:
# 8088/tcp  - HTTP Dispatch / SDK / Documentation Server
# 22101/udp - Game Server KCP Protocol
# 22101/tcp - Game Server TCP
# 22102/tcp - Dispatch Region Server
# 443/tcp   - HTTPS Gateway (if TLS enabled)
EXPOSE 8088/tcp 22101/udp 22101/tcp 22102/tcp 443/tcp

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["java", "-jar", "LunaGC.jar"]
