# Readme

# InfluxDB and Grafana Monitoring Setup

Contains a pre-configured InfluxDB and Grafana setup for our monitoring system. 

## Prerequisites

- Docker
- Docker Compose

## Quickstart:

1. Clone the repo:
2. Make env - You will needs telegram api token for bot alerts:
   ```bash
   make
   ```
3. Load weights:
    ```bash
    # Download the model file
    gdown --id 1zOzt25XH_zCW47rfnNpKsIbc-O15H6wx -O ai_product_hack_model.zip

    # Unzip the downloaded file
    unzip ai_product_hack_model.zip -d ./onnx && rm ai_product_hack_model.zip
    cp -r onnx inference/ && rm -rf ./onnx
    ```

4. Navigate to the project directory:
    
    ```bash
    cd LLM_Cleaner
    ```
    
5. [alternative] Run make command and input telegram bot and chat ids:
    
    ```bash
    make llm_cleaner_init
    ```
    
6. Run make command (may require sudo rights):
    
    ```bash
    make llm_cleaner_run
    ```
    
    This script should do everything for you.
    
7. Access the Grafana UI in your browser:
    
    ```
    http://localhost:3000
    ```
    
    Default login credentials:
    
    - Username: admin
    - Password: adminpassword
8. Access the InfluxDB UI in your browser:
    
    ```
    http://localhost:8086
    ```
    
    Default login credentials:
    
    - Username: admin
    - Password: adminpassword

## What's Included

- Pre-configured Grafana dashboards for monitoring chat rudeness and inappropriate behavior
- InfluxDB data source setup in Grafana
- Docker Compose files for easy deployment

# Sending data to the Inference Service:

The inference service processes messages and automatically sends the results to InfluxDB. Grafana will then pull this data from InfluxDB for visualization.

## Making a POST Request to the Inference Service

You can send a POST request to the inference service using curl or any HTTP client. Here's an example using curl:

```bash
curl -X POST \
     -H "Content-Type: application/json" \
     -d '{"sender": "user", "text": "Your message here"}' \
     http://localhost:5000/inference
```

Replace "Your message here" with the actual message you want to analyze.

The response will be in JSON format, containing the probabilities:

```json
{
  "probabilities": {
    "Child Sexual Exploitation": 0.7839430570602417,
    "Hate": 0.9150898456573486,
    "Non-Violent Crimes": 0.026126563549041748,
    "Politics": 0.16054880619049072,
    "Prompt Injection": 0.37052857875823975,
    "Sexual Content": 0.9613398909568787,
    "Suicide & Self-Harm": 0.7113082408905029,
    "Violent Crimes": 0.5088530778884888,
    "Материться": 0.9813034534454346
  }
}
```

The inference service will automatically process this data and send it to InfluxDB for storage and later visualization in Grafana.
