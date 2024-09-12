#!/bin/bash

# Make sure both setup scripts are executable
chmod +x setup_cuda.sh setup_cpu.sh substitute_env_vars.sh

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

# Check if NVIDIA GPU is available
if command -v nvidia-smi &> /dev/null && nvidia-smi &> /dev/null
then
    echo "NVIDIA GPU detected. Using CUDA-enabled version."
    ./setup_cuda.sh
else
    echo "No NVIDIA GPU detected. Using CPU-only version."
    ./setup_cpu.sh
fi
