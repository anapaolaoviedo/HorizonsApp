import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var selectedTab: ProfileTab = .dashboard
    @State private var showingLogoutAlert = false
    @State private var showingMUNGame = false
    @State private var showingDesignLabGame = false  // 👈 NEW STATE FOR DESIGN LAB
    @State private var goToChat = false   // 👈 navigation trigger
    
    // 👈 ADD THESE NEW STATE VARIABLES FOR CAREER NAVIGATION
    @State private var selectedCareer: CareerDetail?
    @State private var showingCareerDetail = false

    var body: some View {
        NavigationStack {
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
            .navigationDestination(isPresented: $goToChat) {   // 👈 destination for chat
                ChatScreen()
            }
            .navigationDestination(isPresented: $showingCareerDetail) {   // 👈 ADD THIS NEW DESTINATION
                if let career = selectedCareer {
                    CareerDetailView(career: career)
                }
            }
            .toolbar(.hidden, for: .navigationBar)  // replaces .navigationBarHidden in NavigationStack
        }
        .onAppear { viewModel.loadUserData() }
        .alert("Cerrar Sesión", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Cerrar Sesión", role: .destructive) {
                viewModel.logout()
                isLoggedIn = false
            }
        } message: { Text("¿Estás seguro que quieres cerrar sesión?") }
        .sheet(isPresented: $showingMUNGame) {
            MUNGameView()
        }
        .sheet(isPresented: $showingDesignLabGame) {  // 👈 NEW SHEET FOR DESIGN LAB
            DesignLabGameView()
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
                Button { showingLogoutAlert = true } label: {
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
                    Text("¡Hola, \(viewModel.user?.username ?? "Ellucian")!")
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
                    // Chat → triggers navigation
                    SocratFeatureCard(
                        icon: "bubble.left.and.bubble.right.fill",
                        title: "Chat Vocacional",
                        description: "Conversa sobre tus intereses y recibe orientación personalizada",
                        action: "Iniciar Chat",
                        isAvailable: true,
                        onTap: { goToChat = true }   // 👈 push ChatScreen
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

    // MARK: - Resources Content (UPDATED WITH NAVIGATION)
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

                // Career categories - 👈 UPDATED WITH NAVIGATION CLOSURES
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    CareerCard(
                        icon: "stethoscope",
                        title: "Medicina",
                        subtitle: "Ciencias de la Salud",
                        color: .red,
                        courses: 12,
                        onTap: {
                            selectedCareer = CareerDetail.medicina
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "scale.3d",
                        title: "Derecho",
                        subtitle: "Justicia y Leyes",
                        color: .blue,
                        courses: 8,
                        onTap: {
                            selectedCareer = CareerDetail.derecho
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "paintbrush.fill",
                        title: "Diseño",
                        subtitle: "Arte y Creatividad",
                        color: .purple,
                        courses: 15,
                        onTap: {
                            selectedCareer = CareerDetail.diseno
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "laptopcomputer",
                        title: "Tecnología",
                        subtitle: "Innovación Digital",
                        color: .pink,
                        courses: 20,
                        onTap: {
                            selectedCareer = CareerDetail.tecnologia
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "building.columns.fill",
                        title: "Negocios",
                        subtitle: "Emprendimiento",
                        color: .orange,
                        courses: 10,
                        onTap: {
                            selectedCareer = CareerDetail.negocios
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "globe.americas.fill",
                        title: "Rel. Int.",
                        subtitle: "Diplomacia",
                        color: .mint,
                        courses: 6,
                        onTap: {
                            selectedCareer = CareerDetail.relacionesInternacionales
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "gearshape.fill",
                        title: "Ingenierías",
                        subtitle: "Construcción y desarrollo",
                        color: .green,
                        courses: 7,
                        onTap: {
                            selectedCareer = CareerDetail.ingenieria
                            showingCareerDetail = true
                        }
                    )
                    
                    CareerCard(
                        icon: "book",
                        title: "Humanidades",
                        subtitle: "Literatura y Filosofía",
                        color: .yellow,
                        courses: 7,
                        onTap: {
                            selectedCareer = CareerDetail.humanidades
                            showingCareerDetail = true
                        }
                    )
                }

                Spacer(minLength: 100)
            }
            .padding()
        }
    }

    // MARK: - Games Content (UPDATED WITH DESIGN LAB GAME)
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

                // Featured games (UPDATED)
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
                    
                    // 👈 NEW DESIGN LAB GAME CARD
                    FeaturedDesignGameCard(
                        title: "Design Lab",
                        subtitle: "Arte y Creatividad",
                        description: "Sumérgete en desafíos de diseño real. Descubre tu potencial creativo, dominio técnico y sensibilidad estética a través de proyectos prácticos.",
                        icon: "paintpalette.fill",
                        difficulty: "Principiante",
                        duration: "12 min",
                        players: "850 jugadores",
                        showingDesignLabGame: $showingDesignLabGame
                    )

                    // Coming soon
                    Text("🔜 Próximos Juegos")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    ComingSoonGameCard(title: "Lab Virtual",    subtitle: "Ciencias",         icon: "flask.fill",        color: .green)
                    ComingSoonGameCard(title: "Sala de Tribunal", subtitle: "Derecho",        icon: "scale.3d",         color: .blue)
                    ComingSoonGameCard(title: "Startup Simulator", subtitle: "Negocios",     icon: "building.2.fill",  color: .orange)
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
                TabBarButton(tab: tab, selectedTab: $selectedTab)
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
        case .socrat:    return "brain.head.profile"
        case .resources: return "books.vertical.fill"
        case .games:     return "gamecontroller.fill"
        }
    }

    var title: String {
        switch self {
        case .dashboard: return "Perfil"
        case .socrat:    return "Socrat"
        case .resources: return "Recursos"
        case .games:     return "Juegos"
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
    var onTap: (() -> Void)? = nil   // 👈 closure to trigger navigation

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

            Button(action: { onTap?() }) {
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

// 👈 UPDATED CAREERCARD WITH ONTAP CLOSURE
struct CareerCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let courses: Int
    let onTap: () -> Void   // 👈 ADD THIS CLOSURE

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
            onTap()   // 👈 CALL THE CLOSURE
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

            Text(description)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

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

            Button(action: { showingMUNGame = true }) {
                Text("🚀 Jugar Ahora")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.blue, .purple],
                                       startPoint: .leading,
                                       endPoint: .trailing)
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

// 👈 NEW DESIGN LAB FEATURED GAME CARD
struct FeaturedDesignGameCard: View {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let difficulty: String
    let duration: String
    let players: String
    @Binding var showingDesignLabGame: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.purple)

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
                            .background(Color.purple)
                            .cornerRadius(4)
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }

                Spacer()
            }

            Text(description)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            HStack {
                Label(difficulty, systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.green)

                Label(duration, systemImage: "clock.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(players)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Button(action: { showingDesignLabGame = true }) {
                Text("🎨 Crear Ahora")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(colors: [.pink, .purple],
                                       startPoint: .leading,
                                       endPoint: .trailing)
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

    func loadUserData() { loadMockData() }

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

// 👈 ADD THESE SAMPLE CAREER DETAIL EXTENSIONS
extension CareerDetail {
    static let medicina = CareerDetail(
        title: "Medicina",
        subtitle: "Ciencias de la Salud",
        icon: "stethoscope",
        color: .red,
        description: "La medicina se dedica al diagnóstico, tratamiento y prevención de enfermedades. Los médicos trabajan para mejorar la calidad de vida de las personas mediante la atención médica integral.",
        averageSalary: "$50,000-150,000 MXN/mes",
        jobGrowth: "+8% crecimiento",
        mainAreas: ["Medicina General", "Especialidades Médicas", "Cirugía", "Investigación Médica", "Medicina Preventiva"],
        dailyActivities: ["Consultar pacientes", "Realizar diagnósticos", "Prescribir tratamientos", "Realizar procedimientos", "Actualizar expedientes"],
        workEnvironments: ["Hospitales", "Clínicas", "Consultorios privados", "Centros de investigación"],
        personalityTraits: ["Empatía", "Precisión", "Resistencia al estrés", "Capacidad de decisión", "Ética profesional"],
        hardSkills: [
            Skill(name: "Anatomía y Fisiología", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Diagnóstico Clínico", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Farmacología", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        softSkills: [
            Skill(name: "Empatía", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Comunicación", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Trabajo bajo presión", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Práctica clínica", description: "Experiencia directa con pacientes", methods: ["Residencia", "Rotaciones"])
        ],
        academicPath: [
            AcademicStep(title: "Licenciatura en Medicina", description: "6 años de estudio médico integral", duration: "6 años")
        ],
        careerProgression: [
            CareerStage(title: "Médico General", description: "Práctica médica general", salaryRange: "$30,000-50,000", responsibilities: ["Consultas generales"])
        ],
        recommendedCourses: [
            Course(title: "Anatomía Básica", provider: "UNAM", duration: "3 meses", level: "Básico", isFree: true)
        ],
        recommendedBooks: [
            Book(title: "Gray's Anatomy", author: "Henry Gray", description: "Texto clásico de anatomía humana")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "Colegio Médico", description: "Asociación médica nacional", benefits: ["Certificación"])
        ]
    )
    
    
    
    static let diseno = CareerDetail(
        title: "Diseño",
        subtitle: "Arte y Creatividad",
        icon: "paintbrush.fill",
        color: .purple,
        description: "El diseño combina creatividad y funcionalidad para crear soluciones visuales efectivas. Los diseñadores resuelven problemas de comunicación a través del arte y la estética.",
        averageSalary: "$25,000-80,000 MXN/mes",
        jobGrowth: "+12% crecimiento",
        mainAreas: ["Diseño Gráfico", "UX/UI Design", "Diseño Industrial", "Branding", "Diseño Editorial"],
        dailyActivities: ["Crear conceptos visuales", "Usar software de diseño", "Presentar propuestas", "Colaborar con clientes", "Investigar tendencias"],
        workEnvironments: ["Agencias de publicidad", "Freelance", "Empresas tecnológicas", "Estudios de diseño"],
        personalityTraits: ["Creatividad", "Atención al detalle", "Comunicación visual", "Adaptabilidad", "Pensamiento innovador"],
        hardSkills: [
            Skill(name: "Adobe Creative Suite", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Teoría del Color", importance: 0.8, importanceLevel: "Alto"),
            Skill(name: "Tipografía", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        softSkills: [
            Skill(name: "Creatividad", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Comunicación Visual", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Gestión de Proyectos", importance: 0.75, importanceLevel: "Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Portfolio", description: "Construye un portafolio sólido", methods: ["Proyectos personales", "Prácticas"])
        ],
        academicPath: [
            AcademicStep(title: "Licenciatura en Diseño", description: "4 años de formación en diseño", duration: "4 años")
        ],
        careerProgression: [
            CareerStage(title: "Diseñador Junior", description: "Proyectos básicos de diseño", salaryRange: "$15,000-25,000", responsibilities: ["Diseños simples"])
        ],
        recommendedCourses: [
            Course(title: "Diseño Gráfico Fundamentals", provider: "Domestika", duration: "2 meses", level: "Básico", isFree: false)
        ],
        recommendedBooks: [
            Book(title: "Diseño para el Mundo Real", author: "Victor Papanek", description: "Filosofía y responsabilidad del diseño")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "ADG México", description: "Asociación de diseñadores gráficos", benefits: ["Networking", "Talleres"])
        ]
    )
    
    static let tecnologia = CareerDetail(
        title: "Tecnología",
        subtitle: "Innovación Digital",
        icon: "laptopcomputer",
        color: .pink,
        description: "La tecnología impulsa la innovación digital en todas las industrias. Los profesionales tech crean soluciones software que transforman la manera en que vivimos y trabajamos.",
        averageSalary: "$40,000-120,000 MXN/mes",
        jobGrowth: "+15% crecimiento",
        mainAreas: ["Desarrollo de Software", "Ciencia de Datos", "Ciberseguridad", "Inteligencia Artificial", "DevOps"],
        dailyActivities: ["Programar aplicaciones", "Resolver problemas técnicos", "Colaborar en equipo", "Optimizar sistemas", "Aprender nuevas tecnologías"],
        workEnvironments: ["Startups tecnológicas", "Grandes empresas tech", "Consultoría", "Trabajo remoto", "Freelance"],
        personalityTraits: ["Lógica y análisis", "Persistencia", "Aprendizaje continuo", "Resolución de problemas", "Trabajo en equipo"],
        hardSkills: [
            Skill(name: "Programación", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Bases de Datos", importance: 0.85, importanceLevel: "Muy Alto"),
            Skill(name: "Algoritmos", importance: 0.9, importanceLevel: "Crítico")
        ],
        softSkills: [
            Skill(name: "Resolución de problemas", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Comunicación técnica", importance: 0.8, importanceLevel: "Alto"),
            Skill(name: "Adaptabilidad", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Coding Practice", description: "Practica programación diariamente", methods: ["Proyectos", "GitHub", "Hackathons"])
        ],
        academicPath: [
            AcademicStep(title: "Ingeniería en Sistemas", description: "4-5 años de formación técnica", duration: "4-5 años")
        ],
        careerProgression: [
            CareerStage(title: "Developer Junior", description: "Programación de funcionalidades básicas", salaryRange: "$25,000-40,000", responsibilities: ["Código básico", "Testing"])
        ],
        recommendedCourses: [
            Course(title: "Python para Todos", provider: "Coursera", duration: "3 meses", level: "Básico", isFree: true)
        ],
        recommendedBooks: [
            Book(title: "Clean Code", author: "Robert Martin", description: "Mejores prácticas de programación")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "Software Guru", description: "Comunidad tecnológica mexicana", benefits: ["Eventos", "Networking", "Conferencias"])
        ]
    )
    
    static let negocios = CareerDetail(
        title: "Negocios",
        subtitle: "Emprendimiento",
        icon: "building.columns.fill",
        color: .orange,
        description: "Los negocios se enfocan en crear, desarrollar y gestionar organizaciones exitosas. Incluye estrategia, finanzas, marketing y liderazgo empresarial.",
        averageSalary: "$35,000-100,000 MXN/mes",
        jobGrowth: "+10% crecimiento",
        mainAreas: ["Administración", "Marketing", "Finanzas", "Recursos Humanos", "Emprendimiento"],
        dailyActivities: ["Desarrollar estrategias", "Analizar mercados", "Gestionar equipos", "Negociar acuerdos", "Planificar presupuestos"],
        workEnvironments: ["Corporativos", "Startups", "Consultoría", "Gobierno", "Emprendimiento propio"],
        personalityTraits: ["Liderazgo", "Visión estratégica", "Comunicación", "Toma de decisiones", "Orientación a resultados"],
        hardSkills: [
            Skill(name: "Análisis Financiero", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Marketing Digital", importance: 0.8, importanceLevel: "Alto"),
            Skill(name: "Gestión de Proyectos", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        softSkills: [
            Skill(name: "Liderazgo", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Negociación", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Comunicación", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Experiencia práctica", description: "Desarrolla habilidades empresariales", methods: ["Prácticas", "Proyectos", "Emprendimiento"])
        ],
        academicPath: [
            AcademicStep(title: "Licenciatura en Administración", description: "4 años de formación empresarial", duration: "4 años")
        ],
        careerProgression: [
            CareerStage(title: "Analista Junior", description: "Análisis y soporte empresarial", salaryRange: "$20,000-35,000", responsibilities: ["Análisis", "Reportes"])
        ],
        recommendedCourses: [
            Course(title: "Fundamentos de Marketing", provider: "Google Digital Garage", duration: "2 meses", level: "Básico", isFree: true)
        ],
        recommendedBooks: [
            Book(title: "Good to Great", author: "Jim Collins", description: "Principios de empresas exitosas")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "COPARMEX", description: "Confederación Patronal", benefits: ["Networking", "Capacitación"])
        ]
    )
    
    static let relacionesInternacionales = CareerDetail(
        title: "Relaciones Internacionales",
        subtitle: "Diplomacia",
        icon: "globe.americas.fill",
        color: .mint,
        description: "Las relaciones internacionales estudian las interacciones entre países, organizaciones internacionales y actores globales para promover la cooperación y resolver conflictos.",
        averageSalary: "$30,000-85,000 MXN/mes",
        jobGrowth: "+6% crecimiento",
        mainAreas: ["Diplomacia", "Comercio Internacional", "Organismos Internacionales", "ONGs", "Análisis Político"],
        dailyActivities: ["Analizar situaciones geopolíticas", "Negociar acuerdos", "Redactar informes", "Participar en conferencias", "Coordinar proyectos internacionales"],
        workEnvironments: ["Embajadas", "Ministerios", "Organismos internacionales", "ONGs", "Empresas multinacionales"],
        personalityTraits: ["Visión global", "Diplomacia", "Multiculturalidad", "Análisis crítico", "Comunicación intercultural"],
        hardSkills: [
            Skill(name: "Análisis Geopolítico", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Idiomas", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Derecho Internacional", importance: 0.8, importanceLevel: "Alto")
        ],
        softSkills: [
            Skill(name: "Diplomacia", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Negociación", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Comunicación intercultural", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Experiencia internacional", description: "Desarrolla perspectiva global", methods: ["Intercambios", "Voluntariado", "Simulacros"])
        ],
        academicPath: [
            AcademicStep(title: "Licenciatura en Relaciones Internacionales", description: "4 años de formación diplomática", duration: "4 años")
        ],
        careerProgression: [
            CareerStage(title: "Analista Internacional", description: "Análisis de asuntos globales", salaryRange: "$20,000-35,000", responsibilities: ["Investigación", "Reportes"])
        ],
        recommendedCourses: [
            Course(title: "Introducción a las Relaciones Internacionales", provider: "edX - UC3M", duration: "6 semanas", level: "Básico", isFree: true)
        ],
        recommendedBooks: [
            Book(title: "Diplomacy", author: "Henry Kissinger", description: "Historia y arte de la diplomacia")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "AMEI", description: "Asociación Mexicana de Estudios Internacionales", benefits: ["Conferencias", "Networking"])
        ]
    )
    
    static let ingenieria = CareerDetail(
        title: "Ingenierías",
        subtitle: "Construcción y Desarrollo",
        icon: "gearshape.fill",
        color: .green,
        description: "Las ingenierías aplican principios científicos y matemáticos para diseñar, construir y mantener estructuras, sistemas y procesos que mejoran la vida humana.",
        averageSalary: "$35,000-95,000 MXN/mes",
        jobGrowth: "+11% crecimiento",
        mainAreas: ["Ingeniería Civil", "Ingeniería Industrial", "Ingeniería Mecánica", "Ingeniería Eléctrica", "Ingeniería Química"],
        dailyActivities: ["Diseñar sistemas", "Realizar cálculos", "Supervisar proyectos", "Resolver problemas técnicos", "Trabajar con equipos"],
        workEnvironments: ["Empresas constructoras", "Industria manufacturera", "Consultoría", "Gobierno", "Investigación"],
        personalityTraits: ["Pensamiento lógico", "Precisión", "Creatividad técnica", "Trabajo en equipo", "Orientación a detalles"],
        hardSkills: [
            Skill(name: "Matemáticas", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "CAD/Diseño", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Física Aplicada", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        softSkills: [
            Skill(name: "Resolución de problemas", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Gestión de proyectos", importance: 0.85, importanceLevel: "Muy Alto"),
            Skill(name: "Trabajo en equipo", importance: 0.8, importanceLevel: "Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Práctica técnica", description: "Desarrolla habilidades de ingeniería", methods: ["Laboratorios", "Proyectos", "Prácticas"])
        ],
        academicPath: [
            AcademicStep(title: "Ingeniería (especialidad)", description: "4-5 años de formación técnica", duration: "4-5 años")
        ],
        careerProgression: [
            CareerStage(title: "Ingeniero Junior", description: "Proyectos técnicos básicos", salaryRange: "$25,000-40,000", responsibilities: ["Diseño", "Análisis"])
        ],
        recommendedCourses: [
            Course(title: "Fundamentos de Ingeniería", provider: "MIT OpenCourseWare", duration: "3 meses", level: "Básico", isFree: true)
        ],
        recommendedBooks: [
            Book(title: "Introduction to Engineering", author: "Paul Wright", description: "Fundamentos de la ingeniería moderna")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "Colegio de Ingenieros", description: "Asociación profesional de ingenieros", benefits: ["Certificación", "Actualización"])
        ]
    )
    
    static let humanidades = CareerDetail(
        title: "Humanidades",
        subtitle: "Literatura y Filosofía",
        icon: "book",
        color: .yellow,
        description: "Las humanidades estudian la cultura humana, incluyendo literatura, filosofía, historia y artes, para comprender la experiencia y expresión humana a través del tiempo.",
        averageSalary: "$20,000-60,000 MXN/mes",
        jobGrowth: "+3% crecimiento",
        mainAreas: ["Literatura", "Filosofía", "Historia", "Lenguas", "Crítica Cultural"],
        dailyActivities: ["Investigar textos", "Escribir ensayos", "Enseñar", "Analizar obras", "Participar en debates"],
        workEnvironments: ["Universidades", "Museos", "Editoriales", "Medios de comunicación", "Instituciones culturales"],
        personalityTraits: ["Pensamiento crítico", "Curiosidad intelectual", "Comunicación escrita", "Análisis profundo", "Sensibilidad cultural"],
        hardSkills: [
            Skill(name: "Investigación", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Escritura académica", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Análisis textual", importance: 0.85, importanceLevel: "Muy Alto")
        ],
        softSkills: [
            Skill(name: "Pensamiento crítico", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Comunicación", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Empatía cultural", importance: 0.8, importanceLevel: "Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(title: "Lectura crítica", description: "Desarrolla análisis profundo", methods: ["Lectura extensiva", "Seminarios", "Escritura"])
        ],
        academicPath: [
            AcademicStep(title: "Licenciatura en Humanidades", description: "4 años de formación humanística", duration: "4 años")
        ],
        careerProgression: [
            CareerStage(title: "Investigador Junior", description: "Investigación y análisis cultural", salaryRange: "$15,000-25,000", responsibilities: ["Investigación", "Escritura"])
        ],
        recommendedCourses: [
            Course(title: "Introducción a la Filosofía", provider: "Universidad de Edimburgo", duration: "4 semanas", level: "Básico", isFree: true)
        ],
        recommendedBooks: [
            Book(title: "Las Humanidades en el Siglo XXI", author: "Martha Nussbaum", description: "Importancia de las humanidades hoy")
        ],
        professionalOrgs: [
            ProfessionalOrganization(name: "Academia Mexicana de la Lengua", description: "Institución de estudios lingüísticos", benefits: ["Investigación", "Publicaciones"])
        ]
    )
}

#Preview {
    ProfileView()
}
