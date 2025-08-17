import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let time = Date()
}

@MainActor
final class ChatVM: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isSending = false

    let userId: String

    init(userId: String) {
        self.userId = userId
        // seed greeting bubble
        messages.append(ChatMessage(
            text: "Hola, soy Socrat IA. ¿Qué te interesa explorar?",
            isUser: false
        ))
    }

    func send() async {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }

        // optimistic append
        messages.append(ChatMessage(text: trimmed, isUser: true))
        input = ""
        isSending = true

        do {
            let reply = try await BrainAPI.shared.send(userId: userId, message: trimmed)
            messages.append(ChatMessage(text: reply, isUser: false))
        } catch {
            messages.append(ChatMessage(text: "⚠️ No pude conectar con BRAIN.\n\(error.localizedDescription)", isUser: false))
        }
        isSending = false
    }
}
