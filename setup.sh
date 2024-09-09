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

# Make sure Grafana has rights to access its DB
sudo chmod -R 777 grafana

# Start the containers
sudo docker-compose up -d

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
