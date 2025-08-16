import SwiftUI

// MARK: - Brand Colors (Horizon)
extension Color {
    static let horizonLime       = Color(hex: "#C3F73A")
    static let horizonLightGreen = Color(hex: "#95E06C")
    static let horizonMint       = Color(hex: "#68B684")
    static let horizonBlue       = Color(hex: "#094D92")
    static let horizonLicorice   = Color(hex: "#1C1018")

    // simple hex init
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >>  8) & 0xFF) / 255.0
        let b = Double( int        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isSignup = false
    @State private var showPassword = false

    var body: some View {
        ZStack {
            // Brand gradient background
            LinearGradient(
                colors: [.horizonBlue, .horizonMint, .horizonLightGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Title
                VStack(spacing: 6) {
                    Text("Horizon")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 3)

                    Text(isSignup ? "Crea tu cuenta" : "¡Bienvenido!")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white.opacity(0.95))
                }

                // Fields
                Group {
                    TextField("Correo electrónico", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(14)
                        .background(.white.opacity(0.15))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25)))
                        .cornerRadius(12)
                        .foregroundColor(.white)

                    HStack {
                        if showPassword {
                            TextField("Contraseña", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .foregroundColor(.white)
                        } else {
                            SecureField("Contraseña", text: $password)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .foregroundColor(.white)
                        }
                        Button {
                            withAnimation { showPassword.toggle() }
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(14)
                    .background(.white.opacity(0.15))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.25)))
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Primary action
                Button(action: {
                    // TODO: hook to backend (login / signup)
                }) {
                    Text(isSignup ? "Crear cuenta" : "Iniciar sesión")
                        .font(.headline)
                        .foregroundColor(.horizonLicorice)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.horizonLime)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.25), radius: 6, y: 3)
                }
                .padding(.horizontal)

                // Toggle login/signup
                Button {
                    withAnimation { isSignup.toggle() }
                } label: {
                    Text(isSignup
                         ? "¿Ya tienes cuenta? Inicia sesión."
                         : "¿No tienes cuenta? Regístrate.")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                }

                // Optional guest mode (keeps flow moving in demo)
                Button {
                    // TODO: activar modo invitado
                } label: {
                    Text("Continuar como invitado")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 4)
                }

                // Tiny privacy note
                Text("Tus datos se manejan con fines educativos. Puedes borrar tu información en cualquier momento en Ajustes.")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }
            .padding(.vertical, 32)
        }
    }
}

// MARK: - Preview
#Preview {
    LoginView()
}
