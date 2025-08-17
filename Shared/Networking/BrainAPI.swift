import Foundation

struct WebhookReq: Codable { let user_id: String; let message: String }
struct WebhookRes: Codable { let reply: String }

final class BrainAPI {
    static let shared = BrainAPI(); private init() {}

    // Simulator -> use localhost. Device -> replace with your laptop LAN IP or ngrok https URL.
    #if targetEnvironment(simulator)
    private let url = URL(string: "http://127.0.0.1:8000/webhook")!
    #else
    private let url = URL(string: "http://192.168.1.34:8000/webhook")! // <- change to your IP
    #endif

    func send(userId: String, message: String) async throws -> String {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(WebhookReq(user_id: userId, message: message))

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(WebhookRes.self, from: data).reply
    }
}
