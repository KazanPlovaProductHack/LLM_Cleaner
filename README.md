# Readme

# InfluxDB and Grafana Monitoring Setup

Contains a pre-configured InfluxDB and Grafana setup for our monitoring system. 

## Prerequisites

- Docker
- Docker Compose

## Quickstart:

1. Unzip the archive:
    
    ```bash
    unzip monitoring-setup.zip
    ```
    
2. Navigate to the extracted directory:
    
    ```bash
    cd monitoring-setup
    ```
    
3. Make the setup script executable:
    
    ```bash
    chmod +x setup.sh
    ```
    
4. Run the setup script (may require sudo rights):
    
    ```bash
    ./setup.sh
    ```
    
    This script should do everything for you.
    
5. Access the Grafana UI in your browser:
    
    ```
    http://localhost:3000
    ```
    
    Default login credentials:
    
    - Username: admin
    - Password: adminpassword
6. Access the InfluxDB UI in your browser:
    
    ```
    http://localhost:8086
    ```
    
    Default login credentials:
    
    - Username: admin
    - Password: adminpassword

## What's Included

- Pre-configured Grafana dashboards for monitoring chat rudeness and inappropriate behavior
- InfluxDB data source setup in Grafana
- Docker Compose file for easy deployment

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

The response will be in JSON format, containing the original message data (a little broken at the moment) along with the inference results:

```json
{
  "msg_data": {
    "sender": "user",
    "text": "Your message here"
  },
  "fraud_probs": {
    "rudeness": 0.1,
    "intim": 0.05,
    "harm": 0.01
  },
  "fraud_verdicts": {
    "rudeness": 0,
    "intim": 0,
    "harm": 0
  }
}
```

The inference service will automatically process this data and send it to InfluxDB for storage and later visualization in Grafana.