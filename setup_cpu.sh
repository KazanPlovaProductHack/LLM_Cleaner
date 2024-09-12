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

echo "Using CPU-only version."

# Make sure Grafana has rights to access its DB
sudo chmod -R 777 grafana
# Do the same for InfluxDB
sudo chmod -R 777 influxdb
# Build the inference image
sudo docker build -t llm_cleaner-inference:cpu -f ./inference/Dockerfile.cpu ./inference
# Start the containers
sudo -E docker-compose -f docker-compose-cpu.yml up -d --build

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