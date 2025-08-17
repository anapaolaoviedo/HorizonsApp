import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var selectedTab: ProfileTab = .dashboard
    @State private var showingLogoutAlert = false
    @State private var showingMUNGame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // YOUR BEAUTIFUL GRADIENT BACKGROUND
                LinearGradient(colors: [.horizonLightGreen, .horizonMint],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Header
                    headerView
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        dashboardContent
                            .tag(ProfileTab.dashboard)
                        
                        socratContent
                            .tag(ProfileTab.socrat)
                        
                        resourcesContent
                            .tag(ProfileTab.resources)
                        
                        gamesContent
                            .tag(ProfileTab.games)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom Tab Bar
                    customTabBar
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadUserData()
        }
        .alert("Cerrar Sesión", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                viewModel.logout()
                isLoggedIn = false
            }
        } message: {
            Text("¿Estás seguro que quieres cerrar sesión?")
        }
        .sheet(isPresented: $showingMUNGame) {  // ← AGREGAR AQUÍ
                    MUNGameView()
                }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                // Logo
                HStack(spacing: 8) {
                    Image(systemName: "compass.drawing")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    Text("Horizons")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Profile button
                Button {
                    showingLogoutAlert = true
                } label: {
                    Image(systemName: "power")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // User info card
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(viewModel.user?.username.prefix(1).uppercased() ?? "U")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("¡Hola, \(viewModel.user?.username ?? "Usuario")!")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Miembro desde \(viewModel.memberSince ?? "Agosto 2025")")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Quick stat
                VStack(spacing: 2) {
                    Text("\(viewModel.currentStreak)")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text("días")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding()
    }
    
    // MARK: - Dashboard Content
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress overview
                progressOverview
                
                // Life bars
                lifeBarsSection
                
                // Quick actions
                quickActionsSection
                
                // Recent achievements
                recentAchievementsSection
                
                Spacer(minLength: 100) // Space for tab bar
            }
            .padding()
        }
    }
    
    // MARK: - Progress Overview
    private var progressOverview: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            ProgressCard(
                title: "Juegos",
                value: "\(viewModel.gamesPlayed)",
                icon: "gamecontroller.fill",
                color: .blue,
                subtitle: "completados"
            )
            
            ProgressCard(
                title: "Carreras",
                value: "\(viewModel.careersExplored)",
                icon: "compass.drawing",
                color: .green,
                subtitle: "exploradas"
            )
            
            ProgressCard(
                title: "Tiempo",
                value: viewModel.totalTimeSpent,
                icon: "clock.fill",
                color: .orange,
                subtitle: "invertido"
            )
            
            ProgressCard(
                title: "Nivel",
                value: "Novato",
                icon: "star.fill",
                color: .yellow,
                subtitle: "actual"
            )
        }
    }
    
    // MARK: - Life Bars Section
    private var lifeBarsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Tu Progreso Vocacional")
                .font(.headline.bold())
                .foregroundColor(.horizonLicorice)
            
            VStack(spacing: 12) {
                LifeBar(label: "Exploración", value: viewModel.explorationProgress, color: .blue)
                LifeBar(label: "Autoconocimiento", value: viewModel.selfKnowledgeProgress, color: .green)
                LifeBar(label: "Alineación", value: viewModel.alignmentProgress, color: .orange)
                LifeBar(label: "Listo para decidir", value: viewModel.decisionReadiness, color: .purple)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("🚀 Acciones Rápidas")
                .font(.headline.bold())
                .foregroundColor(.horizonLicorice)
            
            VStack(spacing: 12) {
                QuickActionButton(
                    title: "Jugar MUN Simulator",
                    subtitle: "Nuevo juego disponible",
                    icon: "globe.americas.fill",
                    color: .blue,
                    action: { selectedTab = .games }
                )
                
                QuickActionButton(
                    title: "Hablar con Socrat",
                    subtitle: "Obtén orientación IA",
                    icon: "brain.head.profile",
                    color: .purple,
                    action: { selectedTab = .socrat }
                )
                
                QuickActionButton(
                    title: "Explorar Carreras",
                    subtitle: "Descubre nuevas opciones",
                    icon: "books.vertical.fill",
                    color: .green,
                    action: { selectedTab = .resources }
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Recent Achievements
    private var recentAchievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏆 Logros Recientes")
                .font(.headline.bold())
                .foregroundColor(.horizonLicorice)
            
            VStack(spacing: 12) {
                AchievementRow(
                    icon: "star.fill",
                    title: "¡Bienvenido a Horizons!",
                    description: "Completaste tu perfil",
                    color: .yellow,
                    isNew: true
                )
                
                AchievementRow(
                    icon: "flame.fill",
                    title: "Racha de 5 días",
                    description: "Sigues explorando constantemente",
                    color: .orange,
                    isNew: false
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Socrat Content
    private var socratContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("🧠 Socrat IA")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Tu asistente de orientación vocacional")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Socrat features
                VStack(spacing: 16) {
                    SocratFeatureCard(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Chat Vocacional",
                        description: "Conversa sobre tus intereses y recibe orientación personalizada",
                        action: "Iniciar Chat",
                        isAvailable: true
                    )
                    
                    SocratFeatureCard(
                        icon: "lightbulb.fill",
                        title: "Recomendaciones IA",
                        description: "Análisis inteligente de tu perfil para sugerir carreras ideales",
                        action: "Ver Recomendaciones",
                        isAvailable: true
                    )
                    
                    SocratFeatureCard(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "Análisis Predictivo",
                        description: "Proyecciones de éxito en diferentes campos profesionales",
                        action: "Analizar",
                        isAvailable: false
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Resources Content
    private var resourcesContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Biblioteca de Carreras")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Explora el mundo profesional")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Career categories
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    CareerCard(
                        icon: "stethoscope",
                        title: "Medicina",
                        subtitle: "Ciencias de la Salud",
                        color: .red,
                        courses: 12
                    )
                    
                    CareerCard(
                        icon: "scale.3d",
                        title: "Derecho",
                        subtitle: "Justicia y Leyes",
                        color: .blue,
                        courses: 8
                    )
                    
                    CareerCard(
                        icon: "paintbrush.fill",
                        title: "Diseño",
                        subtitle: "Arte y Creatividad",
                        color: .purple,
                        courses: 15
                    )
                    
                    CareerCard(
                        icon: "laptopcomputer",
                        title: "Tecnología",
                        subtitle: "Innovación Digital",
                        color: .pink,
                        courses: 20
                    )
                    
                    CareerCard(
                        icon: "building.columns.fill",
                        title: "Negocios",
                        subtitle: "Emprendimiento",
                        color: .orange,
                        courses: 10
                    )
                    
                    CareerCard(
                        icon: "globe.americas.fill",
                        title: "Rel. Int.",
                        subtitle: "Diplomacia",
                        color: .mint,
                        courses: 6
                    )
                    
                    CareerCard(
                        icon: "scale.3d",
                        title: "Ingenierias y Ciencias",
                        subtitle: "Construcción y desarrollo ",
                        color: .green,
                        courses: 7
                    )
                    
                    CareerCard(
                        icon: "book",
                        title: "Humanidades",
                        subtitle: "Literatura y Filosofía",
                        color: .yellow,
                        courses: 7
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Games Content
    private var gamesContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("🎮 Career Games")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Aprende jugando")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Featured game
                VStack(spacing: 16) {
                    FeaturedGameCard(
                        title: "MUN Simulator",
                        subtitle: "Relaciones Internacionales",
                        description: "Representa a un país en una crisis diplomática. Tus decisiones revelarán tu potencial en relaciones internacionales, derecho internacional y liderazgo.",
                        icon: "globe.americas.fill",
                        difficulty: "Intermedio",
                        duration: "15 min",
                        players: "1.2k jugadores",
                        showingMUNGame: $showingMUNGame
                    )
                    
                    // Coming soon
                    Text("🔜 Próximos Juegos")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    ComingSoonGameCard(
                        title: "Lab Virtual",
                        subtitle: "Ciencias",
                        icon: "flask.fill",
                        color: .green
                    )
                    
                    ComingSoonGameCard(
                        title: "Sala de Tribunal",
                        subtitle: "Derecho",
                        icon: "scale.3d",
                        color: .blue
                    )
                    
                    ComingSoonGameCard(
                        title: "Startup Simulator",
                        subtitle: "Negocios",
                        icon: "building.2.fill",
                        color: .orange
                    )
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    selectedTab: $selectedTab
                )
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -2)
        )
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

// MARK: - Supporting Types and Views

enum ProfileTab: CaseIterable {
    case dashboard, socrat, resources, games
    
    var icon: String {
        switch self {
        case .dashboard: return "person.circle.fill"
        case .socrat: return "brain.head.profile"
        case .resources: return "books.vertical.fill"
        case .games: return "gamecontroller.fill"
        }
    }
    
    var title: String {
        switch self {
        case .dashboard: return "Perfil"
        case .socrat: return "Socrat"
        case .resources: return "Recursos"
        case .games: return "Juegos"
        }
    }
}

struct TabBarButton: View {
    let tab: ProfileTab
    @Binding var selectedTab: ProfileTab
    
    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.title3)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.horizonLicorice)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.horizonLicorice)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct QuickActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.callout.bold())
                        .foregroundColor(.horizonLicorice)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.7))
            .cornerRadius(12)
        }
    }
}

struct AchievementRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isNew: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.callout.bold())
                        .foregroundColor(.horizonLicorice)
                    
                    if isNew {
                        Text("NUEVO")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct SocratFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let action: String
    let isAvailable: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(isAvailable ? .blue : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(.horizonLicorice)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            Button(action: {
                // TODO: Implement
            }) {
                Text(isAvailable ? action : "Próximamente")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isAvailable ? Color.blue : Color.gray)
                    .cornerRadius(10)
            }
            .disabled(!isAvailable)
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct CareerCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let courses: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.horizonLicorice)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(courses) recursos")
                    .font(.caption2)
                    .foregroundColor(color)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            // TODO: Navigate to career
        }
    }
}

struct FeaturedGameCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let difficulty: String
    let duration: String
    let players: String
    @Binding var showingMUNGame: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Header - ESTO FALTABA
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.title2.bold())
                            .foregroundColor(.horizonLicorice)
                        
                        Text("NUEVO")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(4)
                    }
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            // Description - ESTO TAMBIÉN FALTABA
            Text(description)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            // Stats - Y ESTO TAMBIÉN
            HStack {
                Label(difficulty, systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Label(duration, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(players)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Play button - ESTE YA LO TENÍAS
            Button(action: {
                showingMUNGame = true
            }) {
                Text("🚀 Jugar Ahora")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ComingSoonGameCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color.opacity(0.6))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.callout.bold())
                    .foregroundColor(.horizonLicorice.opacity(0.6))
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("Próximamente")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray)
                .cornerRadius(6)
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// Keep your existing LifeBar component but with color parameter
struct LifeBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value * 100))%").font(.caption2.bold()).foregroundColor(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8).fill(.black.opacity(0.08))
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: geo.size.width * value)
                        .animation(.easeInOut(duration: 0.8), value: value)
                }
            }
            .frame(height: 10)
        }
    }
}

// Keep your existing ProfileViewModel...
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var explorationProgress: Double = 0.0
    @Published var selfKnowledgeProgress: Double = 0.0
    @Published var alignmentProgress: Double = 0.0
    @Published var decisionReadiness: Double = 0.0
    
    @Published var gamesPlayed: Int = 0
    @Published var careersExplored: Int = 0
    @Published var totalTimeSpent: String = "0h"
    @Published var currentStreak: Int = 0
    @Published var memberSince: String?
    
    @Published var recentActivities: [RecentActivity] = []
    
    func loadUserData() {
        loadMockData()
    }
    
    func logout() {
        user = nil
        explorationProgress = 0.0
        selfKnowledgeProgress = 0.0
        alignmentProgress = 0.0
        decisionReadiness = 0.0
        gamesPlayed = 0
        careersExplored = 0
        totalTimeSpent = "0h"
        currentStreak = 0
        recentActivities = []
    }
    
    private func loadMockData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.explorationProgress = 0.35
            self.selfKnowledgeProgress = 0.50
            self.alignmentProgress = 0.40
            self.decisionReadiness = 0.25
            
            self.gamesPlayed = 1
            self.careersExplored = 1
            self.totalTimeSpent = "1.2h"
            self.currentStreak = 0
            self.memberSince = "Agosto 2025"
        }
    }
}

struct RecentActivity {
    let id: Int
    let title: String
    let timeAgo: String
    let icon: String
}

// Add these color extensions if you don't have them
extension Color {
    static let horizonLightGreen = Color.green.opacity(0.7)
    static let horizonMint = Color.mint
    static let horizonLime = Color.green
    static let horizonBlue = Color.blue
    static let horizonLicorice = Color.black
}

#Preview {
    ProfileView()
}
