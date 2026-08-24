#!/bin/bash
set -e

# Configuration variables with defaults
MONGO_HOST="${MONGO_HOST:-mongodb}"
MONGO_PORT="${MONGO_PORT:-27017}"
MONGO_URI="${MONGO_URI:-mongodb://${MONGO_HOST}:${MONGO_PORT}}"
JAVA_OPTS="${JAVA_OPTS:--Xms1024M -Xmx4096M -XX:+UseG1GC}"

cd /app

# Ensure runtime directories exist
mkdir -p /app/data /app/resources /app/resources/BinOutput /app/resources/ExcelBinOutput /app/plugins /app/logs /app/packets /app/cache

# Seed default data files if missing
if [ -d "/app/defaults/data" ]; then
    for file in /app/defaults/data/*; do
        if [ -f "$file" ]; then
            fname=$(basename "$file")
            if [ ! -f "/app/data/$fname" ]; then
                echo "[LunaGC] Seeding default data file: $fname"
                cp "$file" "/app/data/$fname"
            fi
        fi
    done
fi

# Seed default keystore if missing
if [ ! -f "/app/keystore.p12" ] && [ -f "/app/defaults/keystore.p12" ]; then
    echo "[LunaGC] Seeding default keystore.p12"
    cp /app/defaults/keystore.p12 /app/keystore.p12
fi

# Generate canonical config.json if not present
if [ ! -f "/app/config.json" ]; then
    echo "[LunaGC] Initializing default config.json..."
    java -jar /app/LunaGC.jar -version >/dev/null 2>&1 || true
fi

# If config.json exists, update MongoDB connection URI and accessAddress if configured
if [ -f "/app/config.json" ]; then
    echo "[LunaGC] Applying MongoDB connection: ${MONGO_URI}"
    tmp_config=$(mktemp)
    jq --arg uri "$MONGO_URI" \
       '.databaseInfo.server.connectionUri = $uri | .databaseInfo.game.connectionUri = $uri' \
       /app/config.json > "$tmp_config" && mv "$tmp_config" /app/config.json

    if [ -n "$ACCESS_ADDRESS" ]; then
        echo "[LunaGC] Applying accessAddress: ${ACCESS_ADDRESS}"
        jq --arg addr "$ACCESS_ADDRESS" \
           '.server.http.accessAddress = $addr | .server.game.accessAddress = $addr' \
           /app/config.json > "$tmp_config" && mv "$tmp_config" /app/config.json
    fi

    if [ -n "$HTTP_BIND_PORT" ]; then
        jq --argjson port "$HTTP_BIND_PORT" \
           '.server.http.bindPort = $port' \
           /app/config.json > "$tmp_config" && mv "$tmp_config" /app/config.json
    fi

    if [ -n "$GAME_BIND_PORT" ]; then
        jq --argjson port "$GAME_BIND_PORT" \
           '.server.game.bindPort = $port' \
           /app/config.json > "$tmp_config" && mv "$tmp_config" /app/config.json
    fi

    # Enable Web GM Handbook UI
    jq '.server.game.gameOptions.handbook.enable = true | .server.game.gameOptions.handbook.allowCommands = true' \
       /app/config.json > "$tmp_config" && mv "$tmp_config" /app/config.json
fi

# Check for resources
if [ ! -d "/app/resources/ExcelBinOutput" ] || [ -z "$(ls -A /app/resources/ExcelBinOutput 2>/dev/null)" ]; then
    echo "================================================================================"
    echo "[LunaGC] NOTE: Game resources are missing in '/app/resources'."
    echo "[LunaGC] Please download resources from https://github.com/girluh/LunaGC-Resources"
    echo "[LunaGC] and place them in the './resources' folder on your host machine."
    echo "================================================================================"
fi

# If the command starts with java, pass JAVA_OPTS
if [ "$1" = "java" ]; then
    shift
    echo "[LunaGC] Starting LunaGC server with JVM options: ${JAVA_OPTS}"
    exec java $JAVA_OPTS "$@"
fi

# Otherwise execute passed command directly (e.g. bash, sh, custom arguments)
exec "$@"
