import SwiftUI

struct CareerDetailView: View {
    let career: CareerDetail
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CareerDetailViewModel()
    @State private var selectedTab: CareerTab = .overview
    @State private var showingUniversityList = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient matching app theme
                LinearGradient(
                    colors: [.horizonBlue.opacity(0.8), .horizonMint.opacity(0.6), .horizonLightGreen.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Tab content
                    TabView(selection: $selectedTab) {
                        overviewContent
                            .tag(CareerTab.overview)
                        
                        skillsContent
                            .tag(CareerTab.skills)
                        
                        pathwaysContent
                            .tag(CareerTab.pathways)
                        
                        resourcesContent
                            .tag(CareerTab.resources)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Custom tab bar
                    customTabBar
                }
            }
            .onAppear {
                viewModel.loadCareerData(career)
            }
        }
        .sheet(isPresented: $showingUniversityList) {
            UniversityListView(career: career.title)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            // Navigation and career icon
            HStack {
                Button("← Volver") {
                    dismiss()
                }
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                // Match compatibility indicator
                VStack(spacing: 2) {
                    Text("\(viewModel.matchPercentage)%")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Match")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                )
            }
            
            // Career header card
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Career icon
                    ZStack {
                        Circle()
                            .fill(career.color.opacity(0.3))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: career.icon)
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(career.title)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text(career.subtitle)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.9))
                        
                        HStack(spacing: 16) {
                            Label("\(career.averageSalary)", systemImage: "dollarsign.circle.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Label("\(career.jobGrowth)", systemImage: "chart.line.uptrend.xyaxis")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding()
    }
    
    // MARK: - Overview Content
    private var overviewContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Description
                CareerSectionCard(
                    title: "¿Qué es el Derecho?",
                    icon: "book.fill",
                    color: .blue
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(career.description)
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.leading)
                        
                        Text("Áreas principales:")
                            .font(.callout.bold())
                            .foregroundColor(.white)
                            .padding(.top, 8)
                        
                        ForEach(career.mainAreas, id: \.self) { area in
                            HStack {
                                Circle()
                                    .fill(career.color)
                                    .frame(width: 6, height: 6)
                                
                                Text(area)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // Daily activities
                CareerSectionCard(
                    title: "Un día típico incluye:",
                    icon: "clock.fill",
                    color: .orange
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.dailyActivities, id: \.self) { activity in
                            DailyActivityRow(activity: activity)
                        }
                    }
                }
                
                // Work environments
                CareerSectionCard(
                    title: "¿Dónde trabajan?",
                    icon: "building.2.fill",
                    color: .green
                ) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(career.workEnvironments, id: \.self) { environment in
                            WorkEnvironmentChip(environment: environment)
                        }
                    }
                }
                
                // Personality fit
                CareerSectionCard(
                    title: "Personalidad ideal",
                    icon: "person.fill",
                    color: .purple
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.personalityTraits, id: \.self) { trait in
                            PersonalityTraitRow(trait: trait)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Skills Content
    private var skillsContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hard skills
                CareerSectionCard(
                    title: "Habilidades Técnicas",
                    icon: "brain.head.profile",
                    color: .blue
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.hardSkills, id: \.name) { skill in
                            SkillProgressRow(skill: skill)
                        }
                    }
                }
                
                // Soft skills
                CareerSectionCard(
                    title: "Habilidades Interpersonales",
                    icon: "heart.fill",
                    color: .pink
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.softSkills, id: \.name) { skill in
                            SkillProgressRow(skill: skill)
                        }
                    }
                }
                
                // Skills development
                CareerSectionCard(
                    title: "Cómo desarrollar estas habilidades",
                    icon: "lightbulb.fill",
                    color: .yellow
                ) {
                    VStack(spacing: 16) {
                        ForEach(career.skillDevelopment, id: \.title) { development in
                            SkillDevelopmentCard(development: development)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Pathways Content
    private var pathwaysContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Academic path
                CareerSectionCard(
                    title: "Ruta Académica",
                    icon: "graduationcap.fill",
                    color: .blue
                ) {
                    VStack(spacing: 16) {
                        ForEach(career.academicPath.indices, id: \.self) { index in
                            AcademicStepCard(
                                step: career.academicPath[index],
                                stepNumber: index + 1,
                                isLast: index == career.academicPath.count - 1
                            )
                        }
                    }
                }
                
                // Career progression
                CareerSectionCard(
                    title: "Progresión Profesional",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                ) {
                    VStack(spacing: 16) {
                        ForEach(career.careerProgression.indices, id: \.self) { index in
                            CareerProgressionCard(
                                stage: career.careerProgression[index],
                                level: index + 1
                            )
                        }
                    }
                }
                
                // Quick action button
                Button("Ver Universidades con esta Carrera 🎓") {
                    showingUniversityList = true
                }
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(radius: 4)
                .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Resources Content
    private var resourcesContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Recommended courses
                CareerSectionCard(
                    title: "Cursos Recomendados",
                    icon: "play.rectangle.fill",
                    color: .blue
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.recommendedCourses, id: \.title) { course in
                            CourseCard(course: course)
                        }
                    }
                }
                
                // Books and reading
                CareerSectionCard(
                    title: "Lecturas Esenciales",
                    icon: "books.vertical.fill",
                    color: .orange
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.recommendedBooks, id: \.title) { book in
                            BookCard(book: book)
                        }
                    }
                }
                
                // Professional organizations
                CareerSectionCard(
                    title: "Organizaciones Profesionales",
                    icon: "building.columns.fill",
                    color: .purple
                ) {
                    VStack(spacing: 12) {
                        ForEach(career.professionalOrgs, id: \.name) { org in
                            ProfessionalOrgCard(organization: org)
                        }
                    }
                }
                
                Spacer(minLength: 100)
            }
            .padding()
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack {
            ForEach(CareerTab.allCases, id: \.self) { tab in
                CareerTabButton(tab: tab, selectedTab: $selectedTab)
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

// MARK: - Supporting Views

struct CareerSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let content: Content
    
    init(title: String, icon: String, color: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct DailyActivityRow: View {
    let activity: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            
            Text(activity)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

struct WorkEnvironmentChip: View {
    let environment: String
    
    var body: some View {
        Text(environment)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

struct PersonalityTraitRow: View {
    let trait: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            Text(trait)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

struct SkillProgressRow: View {
    let skill: Skill
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(skill.name)
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(skill.importanceLevel)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [.blue, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * skill.importance, height: 6)
                        .animation(.easeInOut(duration: 0.8), value: skill.importance)
                }
            }
            .frame(height: 6)
        }
    }
}

struct SkillDevelopmentCard: View {
    let development: SkillDevelopment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(development.title)
                .font(.callout.bold())
                .foregroundColor(.white)
            
            Text(development.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
            
            HStack {
                ForEach(development.methods, id: \.self) { method in
                    Text(method)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow.opacity(0.3))
                        )
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct AcademicStepCard: View {
    let step: AcademicStep
    let stepNumber: Int
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 30, height: 30)
                
                Text("\(stepNumber)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                Text(step.duration)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            Spacer()
        }
        .overlay(
            // Connecting line
            VStack {
                if !isLast {
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 2, height: 40)
                        .offset(x: -85, y: 25)
                }
            }
        )
    }
}

struct CareerProgressionCard: View {
    let stage: CareerStage
    let level: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Nivel \(level)")
                    .font(.caption.bold())
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.2))
                    )
                
                Spacer()
                
                Text(stage.salaryRange)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Text(stage.title)
                .font(.callout.bold())
                .foregroundColor(.white)
            
            Text(stage.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
            
            HStack {
                ForEach(stage.responsibilities.prefix(2), id: \.self) { responsibility in
                    Text(responsibility)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.green.opacity(0.3))
                        )
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct CourseCard: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "play.circle.fill")
                .font(.title3)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.title)
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                Text(course.provider)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                HStack {
                    Text(course.duration)
                        .font(.caption2)
                        .foregroundColor(.blue)
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(course.level)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            if course.isFree {
                Text("Gratis")
                    .font(.caption2.bold())
                    .foregroundColor(.green)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct BookCard: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "book.fill")
                .font(.title3)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.callout.bold())
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("por \(book.author)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(book.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ProfessionalOrgCard: View {
    let organization: ProfessionalOrganization
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(organization.name)
                .font(.callout.bold())
                .foregroundColor(.white)
            
            Text(organization.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
            
            HStack {
                ForEach(organization.benefits.prefix(2), id: \.self) { benefit in
                    Text(benefit)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.purple.opacity(0.3))
                        )
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Tab System

enum CareerTab: CaseIterable {
    case overview, skills, pathways, resources
    
    var icon: String {
        switch self {
        case .overview: return "info.circle.fill"
        case .skills: return "brain.head.profile"
        case .pathways: return "map.fill"
        case .resources: return "book.fill"
        }
    }
    
    var title: String {
        switch self {
        case .overview: return "Resumen"
        case .skills: return "Habilidades"
        case .pathways: return "Rutas"
        case .resources: return "Recursos"
        }
    }
}

struct CareerTabButton: View {
    let tab: CareerTab
    @Binding var selectedTab: CareerTab
    
    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.caption)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                
                Text(tab.title)
                    .font(.caption2)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Data Models

struct CareerDetail {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String
    let averageSalary: String
    let jobGrowth: String
    let mainAreas: [String]
    let dailyActivities: [String]
    let workEnvironments: [String]
    let personalityTraits: [String]
    let hardSkills: [Skill]
    let softSkills: [Skill]
    let skillDevelopment: [SkillDevelopment]
    let academicPath: [AcademicStep]
    let careerProgression: [CareerStage]
    let recommendedCourses: [Course]
    let recommendedBooks: [Book]
    let professionalOrgs: [ProfessionalOrganization]
}

struct Skill {
    let name: String
    let importance: Double // 0.0 to 1.0
    let importanceLevel: String
}

struct SkillDevelopment {
    let title: String
    let description: String
    let methods: [String]
}

struct AcademicStep {
    let title: String
    let description: String
    let duration: String
}

struct CareerStage {
    let title: String
    let description: String
    let salaryRange: String
    let responsibilities: [String]
}

struct Course {
    let title: String
    let provider: String
    let duration: String
    let level: String
    let isFree: Bool
}

struct Book {
    let title: String
    let author: String
    let description: String
}

struct ProfessionalOrganization {
    let name: String
    let description: String
    let benefits: [String]
}

// MARK: - ViewModel

@MainActor
class CareerDetailViewModel: ObservableObject {
    @Published var matchPercentage: Int = 0
    @Published var career: CareerDetail?
    
    func loadCareerData(_ career: CareerDetail) {
        self.career = career
        
        // Simulate calculating match percentage based on user profile
        // In real app, this would come from user's game results and profile
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.0)) {
                self.matchPercentage = Int.random(in: 65...95)
            }
        }
    }
}

// MARK: - Sample Data (for Derecho)

extension CareerDetail {
    static let derecho = CareerDetail(
        title: "Derecho",
        subtitle: "Justicia y Leyes",
        icon: "scale.3d",
        color: .blue,
        description: "El Derecho es la disciplina que estudia el conjunto de normas, leyes y regulaciones que rigen una sociedad. Los abogados protegen los derechos de las personas, resuelven conflictos y aseguran que se haga justicia.",
        averageSalary: "$45,000-120,000 MXN/mes",
        jobGrowth: "+6% crecimiento",
        mainAreas: [
            "Derecho Civil y Familiar",
            "Derecho Penal",
            "Derecho Corporativo",
            "Derecho Laboral",
            "Derecho Internacional",
            "Derecho Constitucional"
        ],
        dailyActivities: [
            "Investigar casos y precedentes legales",
            "Redactar documentos jurídicos",
            "Asesorar clientes sobre sus derechos",
            "Representar clientes en audiencias",
            "Negociar acuerdos",
            "Analizar contratos y documentos",
            "Preparar estrategias de defensa"
        ],
        workEnvironments: [
            "Bufetes de abogados",
            "Tribunales",
            "Empresas privadas",
            "Gobierno",
            "ONGs",
            "Trabajo independiente"
        ],
        personalityTraits: [
            "Pensamiento analítico y crítico",
            "Excelente comunicación oral y escrita",
            "Ética y integridad",
            "Capacidad de persuasión",
            "Atención al detalle",
            "Resistencia al estrés"
        ],
        hardSkills: [
            Skill(name: "Investigación Legal", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Redacción Jurídica", importance: 0.85, importanceLevel: "Muy Alto"),
            Skill(name: "Litigación", importance: 0.8, importanceLevel: "Alto"),
            Skill(name: "Negociación", importance: 0.75, importanceLevel: "Alto"),
            Skill(name: "Análisis de Contratos", importance: 0.7, importanceLevel: "Medio-Alto")
        ],
        softSkills: [
            Skill(name: "Comunicación", importance: 0.95, importanceLevel: "Crítico"),
            Skill(name: "Pensamiento Crítico", importance: 0.9, importanceLevel: "Crítico"),
            Skill(name: "Ética Profesional", importance: 0.85, importanceLevel: "Muy Alto"),
            Skill(name: "Trabajo bajo Presión", importance: 0.8, importanceLevel: "Alto"),
            Skill(name: "Empatía", importance: 0.75, importanceLevel: "Alto")
        ],
        skillDevelopment: [
            SkillDevelopment(
                title: "Desarrolla tu argumentación",
                description: "Practica el debate y la construcción de argumentos sólidos",
                methods: ["Debate", "Ensayos", "Moot Court"]
            ),
            SkillDevelopment(
                title: "Mejora tu investigación",
                description: "Aprende a usar bases de datos legales y encontrar precedentes",
                methods: ["Bibliotecas", "Bases de datos", "Casos prácticos"]
            ),
            SkillDevelopment(
                title: "Fortalece tu escritura",
                description: "La redacción clara y precisa es fundamental en derecho",
                methods: ["Práctica diaria", "Cursos de redacción", "Revisión por pares"]
            )
        ],
        academicPath: [
            AcademicStep(
                title: "Licenciatura en Derecho",
                description: "Estudia las bases del sistema jurídico, derecho constitucional, civil, penal y más",
                duration: "4-5 años"
            ),
            AcademicStep(
                title: "Examen de la Barra",
                description: "Presenta el examen profesional para obtener tu cédula profesional",
                duration: "6 meses prep"
            ),
            AcademicStep(
                title: "Especialización (Opcional)",
                description: "Maestría en área específica como derecho corporativo, fiscal o internacional",
                duration: "1-2 años"
            ),
            AcademicStep(
                title: "Práctica Profesional",
                description: "Experiencia en bufetes, gobierno o sector privado",
                duration: "Ongoing"
            )
        ],
        careerProgression: [
            CareerStage(
                title: "Abogado Junior/Pasante",
                description: "Apoyas en investigación legal, redactas documentos básicos y asistes en audiencias",
                salaryRange: "$15,000-25,000 MXN",
                responsibilities: ["Investigación", "Documentos básicos", "Apoyo en casos"]
            ),
            CareerStage(
                title: "Abogado Asociado",
                description: "Manejas casos propios con supervisión, interactúas directamente con clientes",
                salaryRange: "$30,000-50,000 MXN",
                responsibilities: ["Casos propios", "Atención a clientes", "Litigación"]
            ),
            CareerStage(
                title: "Abogado Senior/Socio",
                description: "Diriges equipos legales, desarrollas estrategias y manejas clientes importantes",
                salaryRange: "$60,000-120,000+ MXN",
                responsibilities: ["Liderazgo", "Estrategia", "Desarrollo de negocio"]
            )
        ],
        recommendedCourses: [
            Course(
                title: "Introducción al Derecho Mexicano",
                provider: "UNAM en línea",
                duration: "6 semanas",
                level: "Principiante",
                isFree: true
            ),
            Course(
                title: "Argumentación Jurídica",
                provider: "Coursera - Universidad Austral",
                duration: "4 semanas",
                level: "Intermedio",
                isFree: false
            ),
            Course(
                title: "Derecho Constitucional",
                provider: "edX - Universidad del Rosario",
                duration: "8 semanas",
                level: "Intermedio",
                isFree: true
            ),
            Course(
                title: "Negociación y Resolución de Conflictos",
                provider: "Coursera - Universidad de California",
                duration: "6 semanas",
                level: "Intermedio",
                isFree: false
            )
        ],
        recommendedBooks: [
            Book(
                title: "Introducción al Estudio del Derecho",
                author: "Eduardo García Máynez",
                description: "Texto fundamental para entender los principios básicos del derecho"
            ),
            Book(
                title: "Teoría Pura del Derecho",
                author: "Hans Kelsen",
                description: "Obra clásica sobre la naturaleza y estructura del derecho"
            ),
            Book(
                title: "El Arte de Tener Razón",
                author: "Arthur Schopenhauer",
                description: "Estrategias de argumentación y dialéctica aplicables al derecho"
            ),
            Book(
                title: "Curso de Derecho Civil Mexicano",
                author: "Rojina Villegas",
                description: "Tratado completo sobre derecho civil en México"
            )
        ],
        professionalOrgs: [
            ProfessionalOrganization(
                name: "Barra Mexicana de Abogados",
                description: "La asociación de abogados más prestigiosa de México",
                benefits: ["Networking", "Capacitación", "Prestigio profesional"]
            ),
            ProfessionalOrganization(
                name: "Colegio de Abogados de tu Estado",
                description: "Organización local que regula la práctica profesional",
                benefits: ["Regulación", "Ética profesional", "Eventos locales"]
            ),
            ProfessionalOrganization(
                name: "Instituto de Investigaciones Jurídicas UNAM",
                description: "Centro de investigación y desarrollo del derecho",
                benefits: ["Investigación", "Publicaciones", "Academia"]
            )
        ]
    )
}

// MARK: - University List View (Bonus)

struct UniversityListView: View {
    let career: String
    @Environment(\.dismiss) private var dismiss
    
    let universities = [
        University(name: "UNAM - Facultad de Derecho",
                  location: "Ciudad de México",
                  ranking: "#1 en México",
                  tuition: "Pública - $500 MXN/sem",
                  admissionRate: "10%"),
        University(name: "Universidad Iberoamericana",
                  location: "Ciudad de México",
                  ranking: "#2 Privada",
                  tuition: "$95,000 MXN/sem",
                  admissionRate: "40%"),
        University(name: "ITAM",
                  location: "Ciudad de México",
                  ranking: "#3 en México",
                  tuition: "$180,000 MXN/sem",
                  admissionRate: "25%"),
        University(name: "Universidad de Guadalajara",
                  location: "Guadalajara, Jalisco",
                  ranking: "#4 en México",
                  tuition: "Pública - $800 MXN/sem",
                  admissionRate: "15%"),
        University(name: "Tecnológico de Monterrey",
                  location: "Múltiples campus",
                  ranking: "#5 en México",
                  tuition: "$165,000 MXN/sem",
                  admissionRate: "30%")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.horizonBlue.opacity(0.8), .horizonMint.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 12) {
                        Text("🎓 Universidades")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Mejores opciones para estudiar \(career)")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Universities list
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(universities, id: \.name) { university in
                                UniversityCard(university: university)
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct University {
    let name: String
    let location: String
    let ranking: String
    let tuition: String
    let admissionRate: String
}

struct UniversityCard: View {
    let university: University
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(university.name)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text(university.location)
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Text(university.ranking)
                    .font(.caption.bold())
                    .foregroundColor(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.2))
                    )
            }
            
            VStack(spacing: 8) {
                HStack {
                    Label("Colegiatura: \(university.tuition)", systemImage: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                
                HStack {
                    Label("Admisión: \(university.admissionRate)", systemImage: "person.3.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    CareerDetailView(career: .derecho)
}
