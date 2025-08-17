import SwiftUI

struct ChatScreen: View {
    @StateObject private var vm = ChatVM()

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.messages) { m in
                        HStack {
                            if m.role == .bot {
                                Text(m.text)
                                    .padding(12)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(14)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text(m.text)
                                    .padding(12)
                                    .background(Color.blue.opacity(0.15))
                                    .cornerRadius(14)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }.padding(.horizontal)
                    }
                }
            }
            HStack {
                TextField("Escribe…", text: $vm.input)
                    .textFieldStyle(.roundedBorder)
                Button("Enviar") { Task { await vm.send() } }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Chat Vocacional")
    }
}
