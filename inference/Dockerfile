# Base image for both CPU and CUDA versions
FROM python:3.9-slim-buster as base

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Install CPU-specific PyTorch and ONNX Runtime
RUN pip install --no-cache-dir torch==2.0.1+cpu -f https://download.pytorch.org/whl/torch_stable.html \
    && pip install --no-cache-dir onnxruntime==1.15.1

# CUDA-enabled stage
FROM nvidia/cuda:12.2.0-runtime-ubuntu20.04 as cuda
ENV DEBIAN_FRONTEND=noninteractive

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copy files from base
COPY --from=base /app /app
WORKDIR /app

# Install CUDA-specific packages
RUN pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir torch==2.0.1+cu118 -f https://download.pytorch.org/whl/torch_stable.html \
    && pip3 install --no-cache-dir onnxruntime-gpu==1.15.1

# Final stage
FROM ${BUILD_TYPE:-base} as final

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run a script to check CUDA and then start the inference service
#CMD ["bash", "-c", "python3 inference.py"]
