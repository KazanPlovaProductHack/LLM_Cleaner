import os
from typing import Dict, List, Any, Tuple
import torch
import onnxruntime as ort
from transformers import AutoTokenizer
from influxdb_client import InfluxDBClient, Point
from influxdb_client.client.write_api import SYNCHRONOUS
from datetime import datetime
import json
from flask import Flask, request, jsonify

# Load environment variables
INFLUXDB_URL: str = os.getenv('INFLUXDB_URL', '')
INFLUXDB_TOKEN: str = os.getenv('INFLUXDB_TOKEN', '')
INFLUXDB_ORG: str = os.getenv('INFLUXDB_ORG', '')
INFLUXDB_BUCKET: str = os.getenv('INFLUXDB_BUCKET', '')

# Load tokenizer and ONNX model
tokenizer = AutoTokenizer.from_pretrained("./onnx")

# Try to use CUDA, fall back to CPU if not available
try:
    providers = ['CUDAExecutionProvider', 'CPUExecutionProvider']
    ort_session = ort.InferenceSession("./onnx/model.onnx", providers=providers)
    print("Using CUDA for inference")
except Exception as e:
    print(f"CUDA not available, falling back to CPU: {str(e)}")
    ort_session = ort.InferenceSession("./onnx/model.onnx", providers=['CPUExecutionProvider'])

hypothesis_template: str = "This example is {}."
labels: List[str] = ['rudeness', 'intim', 'harm']  # Simplified list of labels

app = Flask(__name__)

def run_onnx_inference(sequence_to_classify: str, candidate_labels: List[str]) -> List[float]:
    """
    Run ONNX inference on the given sequence with the provided candidate labels.

    Args:
        sequence_to_classify (str): The input text to classify.
        candidate_labels (List[str]): The list of candidate labels.

    Returns:
        List[float]: The probabilities for each label.
    """
    sequence_pairs = [[sequence_to_classify, hypothesis_template.format(label)] for label in candidate_labels]
    inputs = tokenizer(sequence_pairs, return_tensors="pt", padding=True, truncation=True)
    input_feed = {k: v.numpy() for k, v in inputs.items() if k != "token_type_ids"}
    logits = ort_session.run(None, input_feed)[0]
    probs = 1 - torch.sigmoid(torch.tensor(logits[:, 2] - logits[:, 0]))
    return probs.numpy().tolist()

def process_message(message: Dict[str, str]) -> Dict[str, Any]:
    """
    Process a message by running inference and calculating fraud probabilities and verdicts.

    Args:
        message (Dict[str, str]): A dictionary containing the message data.

    Returns:
        Dict[str, Any]: A dictionary containing the processed results.
    """
    probabilities = run_onnx_inference(message['text'], labels)
    fraud_probs = {label: float(prob) for label, prob in zip(labels, probabilities)}
    fraud_verdicts = {label: int(prob > 0.5) for label, prob in fraud_probs.items()}

    result = {
        'msg_data': message,
        'fraud_probs': fraud_probs,
        'fraud_verdicts': fraud_verdicts
    }
    return result

def send_to_influxdb(result: Dict[str, Any]) -> None:
    """
    Send the processed result to InfluxDB.

    Args:
        result (Dict[str, Any]): The processed result to be sent to InfluxDB.
    """
    client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
    write_api = client.write_api(write_options=SYNCHRONOUS)

    point = Point("message") \
        .tag("sender", result['msg_data']['sender']) \
        .field("text", result['msg_data']['text'])

    for label in labels:
        point = point.field(f"prob_{label}", result['fraud_probs'][label])
        point = point.field(f"verdict_{label}", result['fraud_verdicts'][label])

    point = point.time(datetime.utcnow())

    try:
        write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=point)
        print("Datapoint sent successfully")
    except Exception as e:
        print(f"An error occurred while sending the datapoint: {e}")

    client.close()


@app.route('/inference', methods=['POST'])
def inference() -> Tuple[Any, int]:
    """
    Flask route for running inference on incoming messages.

    Returns:
        Tuple[Any, int]: A tuple containing:
            - JSON response with probabilities or an error message
            - HTTP status code
    """
    try:
        message = request.json
        if not isinstance(message, dict) or 'sender' not in message or 'text' not in message:
            return jsonify({
                "error": "Invalid input format. Expected a single message object with 'sender' and 'text' fields."
            }), 400

        result = process_message(message)
        send_to_influxdb(result)

        # Return only the probabilities in the response
        return jsonify({
            "probabilities": result['fraud_probs']
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
