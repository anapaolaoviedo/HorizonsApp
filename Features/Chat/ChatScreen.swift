import SwiftUI

struct ChatScreen: View {
    // You can pass a real userId from your login. For demo, seed one.
    @StateObject private var vm: ChatVM

    init(userId: String = "ios_demo_user") {
        _vm = StateObject(wrappedValue: ChatVM(userId: userId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(vm.messages) { msg in
                            HStack {
                                if msg.isUser { Spacer() }
                                Text(msg.text)
                                    .padding(12)
                                    .background(msg.isUser ? Color.blue.opacity(0.15) : Color.gray.opacity(0.15))
                                    .foregroundColor(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                                if !msg.isUser { Spacer() }
                            }
                            .id(msg.id)
                        }
                        if vm.isSending {
                            HStack {
                                ProgressView().controlSize(.regular)
                                Text("Pensando…")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 6)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }
                .onChange(of: vm.messages) { _ in
                    if let last = vm.messages.last?.id {
                        withAnimation { proxy.scrollTo(last, anchor: .bottom) }
                    }
                }
            }

            // Input bar
            HStack(spacing: 8) {
                TextField("Escribe…", text: $vm.input)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .submitLabel(.send)
                    .onSubmit { Task { await vm.send() } }

                Button {
                    Task { await vm.send() }
                } label: {
                    Text("Enviar")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || vm.isSending)
            }
            .padding(.all, 12)
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Chat Vocacional")
        .navigationBarTitleDisplayMode(.inline)
    }
}
