from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/")
def index():
    return jsonify({"message": "Hello from Jenkins EC2 deploy! v1"})

@app.route("/health")
def health():
    return "OK", 200
