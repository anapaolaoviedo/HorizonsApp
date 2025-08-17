import Foundation

// MARK: - Config (simulator vs device)
enum BrainConfig {
#if targetEnvironment(simulator)
    static let base = URL(string: "http://127.0.0.1:8010")!   // FastAPI BRAIN (simulator)
#else
    // If you test on a real iPhone, replace with your Mac's LAN IP (e.g. 192.168.1.23)
    static let base = URL(string: "http://192.168.0.123:8010")!
#endif
}

// MARK: - Models
struct BrainReply: Decodable { let reply: String }

enum BrainError: LocalizedError {
    case badStatus(Int, String)
    case decode(String)
    var errorDescription: String? {
        switch self {
        case .badStatus(let code, let body): return "HTTP \(code): \(body)"
        case .decode(let raw):               return "No pude leer la respuesta: \(raw)"
        }
    }
}

// MARK: - Client
final class BrainAPI {
    static let shared = BrainAPI()
    private init() {}

    /// Sends a message to BRAIN and returns the reply string.
    func send(userId: String, message: String) async throws -> String {
        var req = URLRequest(url: BrainConfig.base.appending(path: "/webhook"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["user_id": userId, "message": message]
        req.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        // Helpful console log during the hackathon
        #if DEBUG
        print("BRAIN HTTP", http.statusCode, "→", String(data: data, encoding: .utf8) ?? "<no body>")
        #endif

        guard http.statusCode == 200 else {
            throw BrainError.badStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        do {
            return try JSONDecoder().decode(BrainReply.self, from: data).reply
        } catch {
            throw BrainError.decode(String(data: data, encoding: .utf8) ?? "")
        }
    }
}
