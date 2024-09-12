# Base image
FROM python:3.9-slim-buster

# Set the working directory in the container
WORKDIR /app

# Install Python and system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    build-essential \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Copy the requirements file into the container
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install CPU-specific PyTorch and ONNX Runtime
RUN pip install --no-cache-dir torch==2.0.1+cpu -f https://download.pytorch.org/whl/torch_stable.html \
    && pip install --no-cache-dir onnxruntime==1.15.1

RUN gdown --id 1zOzt25XH_zCW47rfnNpKsIbc-O15H6wx -O ai_product_hack_model.zip

# Unzip the downloaded file
RUN unzip ai_product_hack_model.zip && \
    rm ai_product_hack_model.zip

# Copy the rest of the application code
COPY . .

# Make port 5000 available to the world outside this container
EXPOSE 5000