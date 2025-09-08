# heysiri-mini-assistant
heysiri-mini-assistant

# 🧠 MiniSiri – Your Personal Voice/Text Assistant (SwiftUI + Groq LLM + Flask)

MiniSiri is a lightweight personal assistant app built in **SwiftUI** that lets you type or tap commands like **"Play Music"**, **"Call Mom"**, or **"What's the weather?"** and get smart responses. If the command isn't predefined, it sends the request to a **Groq-hosted LLaMA-3 LLM** and shows the response.

It also has a built-in **toxicity checker** to scan the LLM's reply and show a score using a local **Python Flask API** with a machine learning model (Detoxify).

---

## ✨ Features

- ✅ Supports custom typed commands and quick buttons
- ✅ Sends fallback prompts to LLaMA-3 via Groq API
- ✅ Detects toxic responses using a local Python API
- ✅ Provides toxicity score and flag in UI
- ✅ 12+ automated UI tests using `XCTest`
- ❌ Voice input (speech-to-text) was attempted but is currently disabled

---

## 🧩 Tech Stack

| Layer            | Tool/Language       | Purpose |
|------------------|---------------------|---------|
| UI               | SwiftUI             | iOS app layout and interaction |
| Backend (iOS)    | Swift (`LLMService`) | Send requests to Groq + Flask |
| AI Model         | LLaMA 3 (Groq API)  | Generate smart responses |
| Toxicity Check   | Python + Flask + Detoxify | Scan LLM responses for harmful content |
| Testing          | XCTest              | UI testing of command inputs & buttons |

---

## 🖥 How it works

### 📱 iOS App (SwiftUI)
- User types a command or taps a quick button
- If it matches a built-in command (e.g., "Play Music"), a response is shown instantly
- If it's unknown (e.g., "Make coffee"), the app sends it to LLaMA-3 via Groq API
- Once the LLM gives a reply, it is also sent to the Flask server to check for **toxicity**
- Toxicity score is displayed (e.g., `Toxicity Score: 0.76`)
- If high, a 🚨 warning is shown in the app

---

### 🌐 Groq API (LLaMA-3)
- Endpoint: `https://api.groq.com/openai/v1/chat/completions`
- Model used: `llama-3-3-70b-versatile`
- We send the prompt and receive a reply like a chatbot

---

### 🔥 Flask API (Python + Detoxify)
- Endpoint: `http://127.0.0.1:8000/analyze-toxicity`
- Takes the LLM response as input and returns:
  - `score`: 0.0 to 1.0
  - `toxic`: true or false

---

## 🧪 Testing

We used **XCTest** to write UI test cases. These cover:

| Test Case # | What It Checks |
|-------------|----------------|
| 1 | Text input: "play music" returns 🎵 response |
| 2 | Unknown command shows "Thinking..." and uses LLM |
| 3 | Quick button: "Call Mom" works |
| 4 | Quick button: "What's the weather?" works |
| 5 | Empty command shows validation error |
| 6-8 | Other commands like "Set Alarm", "Open Calendar", "Send Message" |
| 9 | Whitespace trimming works |
| 10 | All quick buttons are visible and tappable |
| 11 | Dynamic button loop test |
| 12 | Uses `XCTContext` to show diagnostic steps in case of test failure |

---

## ⚠️ Known Limitations

- ❌ **Voice input** (SpeechRecognizer) was planned but not added due to instability and test complexity
- 🔐 Make sure your Groq API key is kept safe (not in public repos!)
- 🧪 Flask server must be running locally for toxicity detection to work

---

## 🚀 Getting Started

### 1. Run Flask Server (for Toxicity Detection)

```bash
# Create and activate Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Flask and Detoxify
pip install flask torch detoxify

# Run the server (make sure port 8000 is free)
python app.py

Your Flask server should be running at:
http://127.0.0.1:8000/analyze-toxicity

2. Run the SwiftUI App

Open the .xcodeproj or .xcodeworkspace in Xcode

Build and run on iOS Simulator

Type or tap commands and see the response + toxicity score

📸 Screenshots (Optional)

You can add screenshots of the UI here showing:

Command input and response

Toxicity score display

LLM fallback response

Button UI

💡 Future Improvements

✅ Add audio input via SpeechRecognizer

✅ Connect to real-time APIs (weather, calendar, etc.)

✅ Deploy toxicity API online using Render or Railway

✅ Use a local on-device model instead of Groq

🙋‍♂️ Author

Isha Agrawal – Developer, Tester, and Architect of MiniSiri

Tech enthusiast | AI Integrator | LLM Evaluator

📃 License

MIT License – feel free to use, fork, and build on this project!
