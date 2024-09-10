#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null
then
    echo "Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null
then
    echo "Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

# Check if FORCE_CUDA environment variable is set
if [ "$FORCE_CUDA" = "1" ]; then
    echo "CUDA version forced. Using CUDA-enabled version."
    export DOCKER_RUNTIME=nvidia
    export BUILD_TYPE=cuda
else
    # Check if NVIDIA GPU is available
    if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null
    then
        echo "NVIDIA GPU detected. Using CUDA-enabled version."
        export DOCKER_RUNTIME=nvidia
        export BUILD_TYPE=cuda
    else
        echo "No NVIDIA GPU detected. Using CPU-only version."
        export DOCKER_RUNTIME=runc
        export BUILD_TYPE=base
    fi
fi

# Make sure Grafana has rights to access its DB
sudo chmod -R 777 grafana
# Do the same for InfluxDB
sudo chmod -R 777 influxdb
# Start the containers
sudo -E docker-compose up -d --build

# Wait for InfluxDB to be ready
echo "Waiting for InfluxDB to be ready..."
until curl -s http://localhost:8086/health | grep -q "ready"
do
    sleep 5
done

# Restore InfluxDB backup if it exists
if [ -d "influxdb/backup" ]; then
    echo "Restoring InfluxDB backup..."
    docker exec influxdb influx restore /backup
fi

echo "Setup complete! Grafana should be available at http://localhost:3000"
