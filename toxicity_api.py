
from flask import Flask, request, jsonify
from detoxify import Detoxify

app = Flask(__name__)
model = Detoxify('original')

@app.route("/analyze-toxicity", methods=["POST"])
@app.route("/analyze-toxicity", methods=["POST"])
def analyze_toxicity():
    data = request.get_json()
    text = data.get("text", "")
    results = model.predict(text)

    toxic_score = float(results.get("toxicity", 0.0))  # ensure it's serializable
    is_toxic = bool(toxic_score > 0.5)

    return jsonify({
        "toxic": is_toxic,
        "score": toxic_score
    })


    
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)

