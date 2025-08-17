import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: Role
    let text: String
    enum Role { case user, bot }
}

@MainActor
final class ChatVM: ObservableObject {
    @Published var messages: [ChatMessage] = [
        .init(role: .bot, text: "Hola, soy Socrat IA. ¿Qué te interesa explorar?")
    ]
    @Published var input: String = ""

    func send() async {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(.init(role: .user, text: text))
        input = ""
        do {
            let reply = try await BrainAPI.shared.send(userId: "ana01", message: text)
            messages.append(.init(role: .bot, text: reply))
        } catch {
            messages.append(.init(role: .bot, text: "⚠️ No pude conectar con BRAIN."))
        }
    }
}
