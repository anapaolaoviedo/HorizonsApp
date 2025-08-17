import Foundation

// MARK: - Models
struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
}

struct SignupRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct APIErrorResponse: Codable {
    let detail: String
}

// MARK: - API Errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case badResponse(String)
    case serverError(String)
    case invalidData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .badResponse(let message):
            return "Respuesta inválida del servidor: \(message)"
        case .serverError(let message):
            return message
        case .invalidData:
            return "Datos inválidos"
        case .networkError(let error):
            return "Error de conexión: \(error.localizedDescription)"
        }
    }
}

// MARK: - API Service
class APIService: ObservableObject {
    static let shared = APIService()
    
    // Change this to your backend URL
    private let baseURL = "http://127.0.0.1:8000"
    private let session = URLSession.shared
    
    private init() {}
    
    // MARK: - Authentication
    func signup(username: String, email: String, password: String) async throws -> User {
        let url = URL(string: "\(baseURL)/signup")!
        let request = SignupRequest(username: username, email: email, password: password)
        
        return try await performRequest(url: url, method: "POST", body: request)
    }
    
    func login(email: String, password: String) async throws -> User {
        let url = URL(string: "\(baseURL)/login")!
        let request = LoginRequest(email: email, password: password)
        
        return try await performRequest(url: url, method: "POST", body: request)
    }
    
    // MARK: - Health Check
    func healthCheck() async throws -> [String: String] {
        let url = URL(string: "\(baseURL)/healthz")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.badResponse("Invalid response type")
            }
            
            if httpResponse.statusCode >= 400 {
                throw APIError.serverError("Health check failed")
            }
            
            let result = try JSONDecoder().decode([String: String].self, from: data)
            return result
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Generic Request Helper
    private func performRequest<T: Codable, U: Codable>(
        url: URL,
        method: String,
        body: T
    ) async throws -> U {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode request body
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw APIError.invalidData
        }
        
        // Perform request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.badResponse("Invalid response type")
            }
            
            // Handle error responses
            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.detail)
                } else {
                    throw APIError.serverError("Unknown server error")
                }
            }
            
            // Decode success response
            let result = try JSONDecoder().decode(U.self, from: data)
            return result
            
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
