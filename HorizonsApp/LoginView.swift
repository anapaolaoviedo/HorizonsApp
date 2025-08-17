import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showingSignup = false
    
    var body: some View {
        ZStack {
            // YOUR BEAUTIFUL GRADIENT BACKGROUND
            LinearGradient(
                colors: [.horizonBlue, .horizonMint, .horizonLightGreen],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 60)
                    
                    // App Logo/Header
                    logoSection
                    
                    // Login Form
                    loginFormSection
                    
                    // Bottom Actions
                    bottomActionsSection
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 32)
            }
        }
        .sheet(isPresented: $showingSignup) {
            SignupView()
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            ProfileView()
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: 20) {
            // App Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                Image(systemName: "compass.drawing")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.white)
            }
            
            // App Title
            VStack(spacing: 8) {
                Text("Horizons")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Descubre tu verdadera vocación")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    // MARK: - Login Form Section
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // Email Field
                ModernTextField(
                    icon: "envelope.fill",
                    placeholder: "Correo electrónico",
                    text: $viewModel.email
                )
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                
                // Password Field
                ModernSecureField(
                    icon: "lock.fill",
                    placeholder: "Contraseña",
                    text: $viewModel.password
                )
                
                // Error Message
                if let errorMessage = viewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        
                        Text(errorMessage)
                            .foregroundColor(.white)
                            .font(.callout)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            
            // Login Button
            Button(action: {
                Task {
                    await viewModel.login()
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .horizonBlue))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                        
                        Text("Iniciar Sesión")
                            .font(.headline.bold())
                    }
                }
                .foregroundColor(.horizonBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            .opacity(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        }
    }
    
    // MARK: - Bottom Actions Section
    private var bottomActionsSection: some View {
        VStack(spacing: 20) {
            // Divider
            HStack {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
                
                Text("o")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 1)
            }
            
            // Signup Button
            Button("¿No tienes cuenta? Crear una nueva") {
                showingSignup = true
            }
            .font(.callout.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.1))
                    )
            )
            
            // Forgot Password
            Button("¿Olvidaste tu contraseña?") {
                // TODO: Implement forgot password
            }
            .font(.callout)
            .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Modern Text Field
struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.callout)
                .foregroundColor(.white)
                .accentColor(.white)
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.6))
                        .font(.callout)
                }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Modern Secure Field
struct ModernSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.callout)
            .foregroundColor(.white)
            .accentColor(.white)
            .placeholder(when: text.isEmpty) {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .font(.callout)
            }
            
            Button {
                isSecure.toggle()
            } label: {
                Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Signup View (Enhanced)
struct SignupView: View {
    @StateObject private var viewModel = SignupViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Same beautiful gradient
            LinearGradient(
                colors: [.blue, .mint, .green],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        HStack {
                            Button("Cancelar") {
                                dismiss()
                            }
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.8))
                            
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            Text("Crear Cuenta")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Únete a la comunidad de Horizons")
                                .font(.callout)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    // Form
                    VStack(spacing: 20) {
                        ModernTextField(
                            icon: "person.fill",
                            placeholder: "Nombre de usuario",
                            text: $viewModel.username
                        )
                        .autocapitalization(.none)
                        
                        ModernTextField(
                            icon: "envelope.fill",
                            placeholder: "Correo electrónico",
                            text: $viewModel.email
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        
                        ModernSecureField(
                            icon: "lock.fill",
                            placeholder: "Contraseña (mín. 6 caracteres)",
                            text: $viewModel.password
                        )
                        
                        // Messages
                        VStack(spacing: 8) {
                            if let errorMessage = viewModel.errorMessage {
                                MessageView(
                                    icon: "exclamationmark.triangle.fill",
                                    message: errorMessage,
                                    color: .white
                                )
                            }
                            
                            if let successMessage = viewModel.successMessage {
                                MessageView(
                                    icon: "checkmark.circle.fill",
                                    message: successMessage,
                                    color: .white
                                )
                            }
                        }
                        .animation(.easeInOut, value: viewModel.errorMessage)
                        .animation(.easeInOut, value: viewModel.successMessage)
                        
                        // Signup Button
                        Button(action: {
                            Task {
                                await viewModel.signup()
                            }
                        }) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .horizonBlue))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.title3)
                                    
                                    Text("Crear Mi Cuenta")
                                        .font(.headline.bold())
                                }
                            }
                            .foregroundColor(.horizonBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(viewModel.isLoading || !viewModel.isFormValid)
                        .opacity(viewModel.isLoading || !viewModel.isFormValid ? 0.6 : 1.0)
                    }
                    
                    // Terms
                    Text("Al crear una cuenta, aceptas nuestros Términos de Servicio y Política de Privacidad")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Message View
struct MessageView: View {
    let icon: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(message)
                .foregroundColor(color)
                .font(.callout)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Placeholder Extension
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

// MARK: - Login ViewModel (Keep existing)
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let apiService = APIService.shared
    
    func login() async {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Por favor completa todos los campos"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await apiService.login(email: email, password: password)
            currentUser = user
            isLoggedIn = true
            print("Login successful: \(user.username)")
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        currentUser = nil
        isLoggedIn = false
        email = ""
        password = ""
    }
}

// MARK: - Signup ViewModel (Keep existing)
@MainActor
class SignupViewModel: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let apiService = APIService.shared
    
    var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && password.count >= 6
    }
    
    func signup() async {
        guard isFormValid else {
            errorMessage = "Por favor completa todos los campos (contraseña mínimo 6 caracteres)"
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let user = try await apiService.signup(username: username, email: email, password: password)
            successMessage = "Cuenta creada exitosamente para \(user.username)"
            print("Signup successful: \(user.username)")
            
            // Clear form after successful signup
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.clearForm()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func clearForm() {
        username = ""
        email = ""
        password = ""
        successMessage = nil
        errorMessage = nil
    }
}

// Add these color extensions if needed


#Preview {
    LoginView()
}
