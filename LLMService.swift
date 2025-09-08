import Foundation

enum MiniSiriError: Error {
    case requestFailed
    case decodingFailed
    case llmFailed(String)
    case toxicityAPIError
}

struct GroqRequest: Codable {
    let model: String
    let messages: [Message]
}

struct Message: Codable {
    let role: String
    let content: String
}

struct GroqResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

class LLMService {
    //private static let apiKey = ""

    static func sendToLLM(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = GroqRequest(
            model: "llama-3.3-70b-versatile",
            messages: [
                Message(role: "system", content: "You are a helpful assistant."),
                Message(role: "user", content: prompt)
            ]
        )

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(MiniSiriError.requestFailed))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(MiniSiriError.llmFailed(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(MiniSiriError.requestFailed))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GroqResponse.self, from: data)
                let reply = decoded.choices.first?.message.content ?? "🤖 No response received."
                completion(.success(reply))
            } catch {
                completion(.failure(MiniSiriError.decodingFailed))
            }
        }.resume()
    }

    static func analyzeToxicity(response: String, completion: @escaping (Result<(Bool, Double), Error>) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/analyze-toxicity") else {
            completion(.failure(MiniSiriError.toxicityAPIError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["text": response]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(MiniSiriError.toxicityAPIError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let toxic = json["toxic"] as? Bool,
                  let score = json["score"] as? Double else {
                completion(.failure(MiniSiriError.toxicityAPIError))
                return
            }

            completion(.success((toxic, score)))
        }.resume()
    }

    static func sendPrompt(_ prompt: String) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            sendToLLM(prompt: prompt) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

