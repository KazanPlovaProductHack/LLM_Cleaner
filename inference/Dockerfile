# Base image for both CUDA and non-CUDA versions
FROM python:3.9-slim-buster as base

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install CPU-only versions of PyTorch and onnxruntime
RUN pip install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir torch==1.10.0 -f https://download.pytorch.org/whl/torch_stable.html \
    && pip3 install --no-cache-dir onnxruntime

# Download the model weights from Google Drive
RUN gdown --id 1zOzt25XH_zCW47rfnNpKsIbc-O15H6wx -O ai_product_hack_model.zip

# Unzip the downloaded file
RUN unzip ai_product_hack_model.zip && \
    rm ai_product_hack_model.zip

# Copy the rest of the application code
COPY . .

# CUDA-enabled version
FROM nvidia/cuda:11.8.0-runtime-ubuntu20.04 as cuda

# Set the working directory in the container
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

# Install CPU-only versions of PyTorch and onnxruntime
RUN pip install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir torch==1.10.0 -f https://download.pytorch.org/whl/torch_stable.html \
    && pip3 install --no-cache-dir onnxruntime

# Copy the rest of the application code
COPY . .

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

# Install CPU-only versions of PyTorch and onnxruntime
RUN pip install --upgrade pip \
    && pip3 install --no-cache-dir -r requirements.txt \
    && pip3 install --no-cache-dir torch==1.10.0 -f https://download.pytorch.org/whl/torch_stable.html \
    && pip3 install --no-cache-dir onnxruntime==1.15.1

# Copy the rest of the application code
COPY . .

# CUDA-enabled version
FROM nvidia/cuda:11.8.0-runtime-ubuntu20.04 as cuda

# Set the working directory in the container
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    cuda-command-line-tools-11-8 \
    && rm -rf /var/lib/apt/lists/*

# Install system dependencies and CUDA libraries
RUN apt-get update && apt-get install -y \
    build-essential \
    libcudnn8 \
    libcublas-11-8 \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip3 install --no-cache-dir -r requirements.txt \
    pip3 install --no-cache-dir onnxruntime-gpu

# Copy the rest of the application code
COPY . .

# Final stage
FROM ${BUILD_TYPE:-base} as final

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run a script to check CUDA and then start the inference service
CMD ["bash", "-c", "\
    echo 'Checking CUDA availability:' && \
    python3 -c 'import torch; print(torch.cuda.is_available())' && \
    echo 'CUDA device count:' && \
    python3 -c 'import torch; print(torch.cuda.device_count())' && \
    echo 'CUDA version:' && \
    python3 -c 'import torch; print(torch.version.cuda)' && \
    echo 'Starting inference service...' && \
    python3 inference.py"]
