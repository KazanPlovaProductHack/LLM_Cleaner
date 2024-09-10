# Use NVIDIA's CUDA 11.8 base image (compatible with onnxruntime-gpu 1.15.1)
FROM nvidia/cuda:11.8.0-runtime-ubuntu20.04

# Set the working directory in the container
WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    cuda-command-line-tools-11-8 \
    && rm -rf /var/lib/apt/lists/*

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements_cpu.txt .
# COPY requirements_cpu.txt .

# # Attempt to install GPU version of onnxruntime, fallback to CPU version if it fails
# RUN pip3 install --no-cache-dir -r requirements_gpu.txt || \
#     (sed -i 's/onnxruntime-gpu/onnxruntime/' requirements.txt && \
#     pip3 install --no-cache-dir -r requirements.txt)

# Copy the rest of the application code
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5010

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