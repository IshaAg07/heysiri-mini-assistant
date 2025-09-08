import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var userCommand: String = ""
    @State private var responseText: String = "Hi! I'm Mini Siri. What can I do for you?"
    @State private var logs: [String] = []
    @State private var player: AVAudioPlayer?

    let commandResponses: [String: String] = [
        "play music": "🎵 Now playing your playlist",
        "set alarm": "⏰ Alarm set for 7:00 AM",
        "what's the weather?": "☁️ 72°F, Partly Cloudy",
        "call mom": "📞 Calling Mom...",
        "open calendar": "📅 Opening your calendar",
        "send message": "📨 Who would you like to message?"
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("🤖 Mini Siri")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 10) {
                ForEach(["play music", "call mom", "what's the weather?"], id: \.self) { cmd in
                    Button(cmd.capitalized) {
                        userCommand = cmd
                        respondToCommand()
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .accessibilityIdentifier("command_\(sanitizeIdentifier(cmd))")
                }
            }

            TextField("Type a command...", text: $userCommand)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    respondToCommand()
                }

            Button("Submit") {
                respondToCommand()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .accessibilityIdentifier("submit_button")

            Button("Stop Music") {
                stopSound()
            }
            .padding(6)
            .foregroundColor(.red)
            .accessibilityIdentifier("stop_music_button")

            Text(responseText)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .animation(.easeIn, value: responseText)

            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(logs.reversed(), id: \.self) { log in
                        Text(log).font(.caption).foregroundColor(.gray)
                    }
                }
            }
            .frame(maxHeight: 150)

            Spacer()
        }
        .padding()
    }

    func respondToCommand() {
        let trimmed = userCommand.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        guard !trimmed.isEmpty else {
            responseText = "Please enter a command."
            logs.append("❗ Empty input received")
            return
        }

        let matchedKey = commandResponses.keys.first(where: {
            trimmed.contains($0) || $0.contains(trimmed)
        })

        if let key = matchedKey, let response = commandResponses[key] {
            responseText = response
            logs.append("🗣️ \(userCommand) → 💬 \(response)")
            if key == "play music" {
                playSound()
            }
        } else {
            responseText = "Thinking... 🤖"
            logs.append("🗣️ \(userCommand) → ⌛ Calling LLM...")

            LLMService.sendToLLM(prompt: trimmed) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let llmReply):
                        responseText = llmReply
                        logs.append("💡 LLM: \(llmReply)")

                        // ✅ Check toxicity via local Flask API
                        LLMService.analyzeToxicity(response: llmReply) { toxicityResult in
                            DispatchQueue.main.async {
                                switch toxicityResult {
                                case .success(let (isToxic, score)):
                                    logs.append("🧪 Toxicity: \(String(format: "%.3f", score)) | \(isToxic ? "🚨 TOXIC" : "✅ Clean")")
                                case .failure(let error):
                                    logs.append("⚠️ Toxicity check failed: \(error.localizedDescription)")
                                }
                            }
                        }

                    case .failure(let error):
                        responseText = "❌ LLM Error: \(error.localizedDescription)"
                        logs.append("LLM Error: \(error.localizedDescription)")
                    }
                }
            }
        }

        userCommand = ""
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "song", withExtension: "mp3") else {
            print("⚠️ Audio file not found.")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Playback failed: \(error.localizedDescription)")
        }
    }

    func stopSound() {
        player?.stop()
        player = nil
    }

    func sanitizeIdentifier(_ command: String) -> String {
        return command
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }
}

