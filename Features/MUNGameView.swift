import SwiftUI

struct MUNGameView: View {
    @StateObject private var viewModel = MUNGameViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.blue.opacity(0.8), .mint.opacity(0.6), .green.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Main content based on game state
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 20) {
                            switch viewModel.gameState {
                            case .intro:
                                introView
                            case .scenario:
                                scenarioView
                            case .decision:
                                decisionView
                            case .result:
                                resultView
                            case .final:
                                finalResultsView
                            }
                        }
                        .padding()
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
        }
        .onAppear {
            viewModel.startGame()
        }
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Button("Salir") {
                dismiss()
            }
            .font(.callout)
            .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            // Progress indicator
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index <= viewModel.currentStep ? Color.white : Color.white.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
            
            // Country flag
            Text(viewModel.selectedCountry.flag)
                .font(.title)
        }
        .padding()
        .background(Color.black.opacity(0.1))
    }
    
    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                
                Text("Simulador MUN")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Crisis Diplomática Internacional")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            VStack(spacing: 20) {
                InfoCard(
                    icon: "person.3.fill",
                    title: "Tu Rol",
                    description: "Representas a un país en el Consejo de Seguridad de la ONU"
                )
                
                InfoCard(
                    icon: "exclamationmark.triangle.fill",
                    title: "La Crisis",
                    description: "Una situación internacional requiere respuesta inmediata"
                )
                
                InfoCard(
                    icon: "target",
                    title: "Tu Objetivo",
                    description: "Toma decisiones que protejan los intereses de tu país y la paz mundial"
                )
            }
            
            Button("🚀 Comenzar Simulación") {
                viewModel.nextStep()
            }
            .font(.headline.bold())
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            )
            .padding(.top, 20)
        }
    }
    
    // MARK: - Scenario View
    private var scenarioView: some View {
        VStack(spacing: 25) {
            // Country selection
            VStack(spacing: 16) {
                Text("Selecciona tu país")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(viewModel.availableCountries, id: \.name) { country in
                        CountryCard(
                            country: country,
                            isSelected: viewModel.selectedCountry.name == country.name
                        ) {
                            viewModel.selectCountry(country)
                        }
                    }
                }
            }
            
            if viewModel.selectedCountry.name != "Selecciona" {
                VStack(spacing: 16) {
                    Text("Perfil de \(viewModel.selectedCountry.name)")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    CountryProfileCard(country: viewModel.selectedCountry)
                    
                    Button("Confirmar País 🌍") {
                        viewModel.nextStep()
                    }
                    .font(.headline.bold())
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(radius: 4)
                    )
                }
            }
        }
    }
    
    // MARK: - Decision View
    private var decisionView: some View {
        VStack(spacing: 25) {
            // Crisis scenario
            CrisisCard(crisis: viewModel.currentCrisis)
            
            // Decision options
            VStack(spacing: 16) {
                Text("¿Cuál es tu posición?")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                ForEach(viewModel.currentCrisis.options, id: \.id) { option in
                    DecisionOptionCard(
                        option: option,
                        isSelected: viewModel.selectedOption?.id == option.id
                    ) {
                        viewModel.selectOption(option)
                    }
                }
            }
            
            if viewModel.selectedOption != nil {
                Button("Enviar Decisión 📤") {
                    viewModel.submitDecision()
                }
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(radius: 4)
            }
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: 25) {
            // Decision outcome
            VStack(spacing: 16) {
                Image(systemName: viewModel.lastResult.isPositive ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(viewModel.lastResult.isPositive ? .green : .orange)
                
                Text(viewModel.lastResult.title)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(viewModel.lastResult.description)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
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
            
            // Skills gained
            if !viewModel.lastResult.skillsGained.isEmpty {
                VStack(spacing: 12) {
                    Text("🎯 Habilidades Demostradas")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(viewModel.lastResult.skillsGained, id: \.self) { skill in
                            SkillBadge(skill: skill)
                        }
                    }
                }
            }
            
            // Continue button
            Button(viewModel.hasMoreScenarios ? "Siguiente Crisis 🌪️" : "Ver Resultados Finales 🏆") {
                viewModel.nextStep()
            }
            .font(.headline.bold())
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(radius: 4)
            )
        }
    }
    
    // MARK: - Final Results View
    private var finalResultsView: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(radius: 10)
                
                Text("¡Simulación Completada!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Perfil Vocacional Actualizado")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Career insights
            VStack(spacing: 20) {
                CareerInsightCard(
                    icon: "globe.desk.fill",
                    title: "Relaciones Internacionales",
                    compatibility: viewModel.finalScores.internationalRelations,
                    description: "Tu capacidad para negociar y entender dinámicas globales"
                )
                
                CareerInsightCard(
                    icon: "person.3.sequence.fill",
                    title: "Liderazgo Político",
                    compatibility: viewModel.finalScores.leadership,
                    description: "Habilidades para tomar decisiones bajo presión"
                )
                
                CareerInsightCard(
                    icon: "scale.3d",
                    title: "Derecho Internacional",
                    compatibility: viewModel.finalScores.law,
                    description: "Comprensión de marcos legales y diplomáticos"
                )
                
                CareerInsightCard(
                    icon: "bubble.left.and.bubble.right.fill",
                    title: "Comunicación Estratégica",
                    compatibility: viewModel.finalScores.communication,
                    description: "Capacidad para articular posiciones complejas"
                )
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Ver Mi Perfil Actualizado 📊") {
                    viewModel.updateUserProfile()
                    dismiss()
                }
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(radius: 4)
                
                Button("Jugar Otra Vez 🔄") {
                    viewModel.restartGame()
                }
                .font(.callout.bold())
                .foregroundColor(.white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        .background(Color.white.opacity(0.1))
                )
            }
        }
    }
}

// MARK: - Supporting Views

struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CountryCard: View {
    let country: Country
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(country.flag)
                    .font(.system(size: 40))
                
                Text(country.name)
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                Text(country.region)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

struct CountryProfileCard: View {
    let country: Country
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(country.flag)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(country.name)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Región: \(country.region)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Características:")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                ForEach(country.characteristics, id: \.self) { characteristic in
                    HStack {
                        Text("•")
                            .foregroundColor(.white.opacity(0.6))
                        Text(characteristic)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct CrisisCard: View {
    let crisis: Crisis
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("CRISIS INTERNACIONAL")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                    
                    Text(crisis.title)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            Text(crisis.description)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            if !crisis.context.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Contexto:")
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    
                    ForEach(crisis.context, id: \.self) { point in
                        HStack(alignment: .top) {
                            Text("•")
                                .foregroundColor(.white.opacity(0.6))
                            Text(point)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct DecisionOptionCard: View {
    let option: DecisionOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: option.icon)
                        .font(.title3)
                        .foregroundColor(option.approach.color)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.approach.rawValue)
                            .font(.caption.bold())
                            .foregroundColor(option.approach.color)
                        
                        Text(option.title)
                            .font(.callout.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                }
                
                Text(option.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    ForEach(option.consequences, id: \.self) { consequence in
                        Text(consequence)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                            )
                    }
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.white.opacity(0.4) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

struct SkillBadge: View {
    let skill: String
    
    var body: some View {
        Text(skill)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

struct CareerInsightCard: View {
    let icon: String
    let title: String
    let compatibility: Double
    let description: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text("\(Int(compatibility * 100))%")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text("Match")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * compatibility, height: 8)
                        .animation(.easeInOut(duration: 1.0), value: compatibility)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Game Models

struct Country {
    let name: String
    let flag: String
    let region: String
    let characteristics: [String]
}

struct Crisis {
    let id: Int
    let title: String
    let description: String
    let context: [String]
    let options: [DecisionOption]
}

struct DecisionOption {
    let id: Int
    let title: String
    let description: String
    let approach: Approach
    let icon: String
    let consequences: [String]
    let skillsAwarded: [String]
}

enum Approach: String, CaseIterable {
    case diplomatic = "Diplomático"
    case economic = "Económico"
    case military = "Militar"
    case humanitarian = "Humanitario"
    
    var color: Color {
        switch self {
        case .diplomatic: return .blue
        case .economic: return .orange
        case .military: return .red
        case .humanitarian: return .green
        }
    }
}

struct DecisionResult {
    let title: String
    let description: String
    let isPositive: Bool
    let skillsGained: [String]
}

struct FinalScores {
    let internationalRelations: Double
    let leadership: Double
    let law: Double
    let communication: Double
}

// MARK: - Game ViewModel

@MainActor
class MUNGameViewModel: ObservableObject {
    @Published var gameState: GameState = .intro
    @Published var currentStep: Int = 0
    @Published var selectedCountry: Country = Country(name: "Selecciona", flag: "🌍", region: "", characteristics: [])
    @Published var selectedOption: DecisionOption?
    @Published var currentCrisis: Crisis = Crisis(id: 0, title: "", description: "", context: [], options: [])
    @Published var lastResult: DecisionResult = DecisionResult(title: "", description: "", isPositive: true, skillsGained: [])
    @Published var finalScores: FinalScores = FinalScores(internationalRelations: 0, leadership: 0, law: 0, communication: 0)
    
    private var decisions: [DecisionOption] = []
    private var currentCrisisIndex = 0
    
    let availableCountries = [
        Country(name: "Estados Unidos", flag: "🇺🇸", region: "América del Norte",
                characteristics: ["Superpotencia global", "Economía desarrollada", "Miembro permanente del CS"]),
        Country(name: "Brasil", flag: "🇧🇷", region: "América del Sur",
                characteristics: ["Líder regional", "Economía emergente", "Defensor del multilateralismo"]),
        Country(name: "Francia", flag: "🇫🇷", region: "Europa",
                characteristics: ["Potencia europea", "Tradición diplomática", "Miembro permanente del CS"]),
        Country(name: "Japón", flag: "🇯🇵", region: "Asia",
                characteristics: ["Potencia tecnológica", "Pacifista", "Contribuyente mayor de la ONU"])
    ]
    
    private let crises = [
        Crisis(
            id: 1,
            title: "Crisis Humanitaria en Conflicto Regional",
            description: "Un conflicto armado ha desplazado a 2 millones de civiles. Los refugiados necesitan ayuda urgente, pero el país vecino rechaza abrir sus fronteras.",
            context: [
                "50,000 niños en riesgo de malnutrición",
                "Hospitales bombardeados sistemáticamente",
                "Organizaciones humanitarias piden acceso seguro"
            ],
            options: [
                DecisionOption(
                    id: 1,
                    title: "Proponer corredores humanitarios protegidos",
                    description: "Negociar con todas las partes para establecer zonas seguras de tránsito de ayuda humanitaria.",
                    approach: .humanitarian,
                    icon: "heart.fill",
                    consequences: ["Alto riesgo", "Impacto directo"],
                    skillsAwarded: ["Negociación", "Empatía", "Liderazgo humanitario"]
                ),
                DecisionOption(
                    id: 2,
                    title: "Sanciones económicas focalizadas",
                    description: "Imponer sanciones a los líderes responsables del bloqueo de ayuda humanitaria.",
                    approach: .economic,
                    icon: "dollarsign.circle.fill",
                    consequences: ["Presión efectiva", "Posibles represalias"],
                    skillsAwarded: ["Análisis económico", "Estrategia", "Presión diplomática"]
                ),
                DecisionOption(
                    id: 3,
                    title: "Resolución multilateral en la ONU",
                    description: "Buscar consenso internacional para una resolución que condene el bloqueo.",
                    approach: .diplomatic,
                    icon: "globe.desk.fill",
                    consequences: ["Proceso lento", "Legitimidad internacional"],
                    skillsAwarded: ["Diplomacia multilateral", "Construcción de consensos", "Derecho internacional"]
                )
            ]
        ),
        Crisis(
            id: 2,
            title: "Disputa Territorial Marítima",
            description: "Dos países aliados disputan una zona rica en recursos naturales. Las tensiones escalaron tras incidentes navales.",
            context: [
                "Rutas comerciales vitales en riesgo",
                "Reservas de gas natural valoradas en $50 mil millones",
                "Comunidades pesqueras afectadas por restricciones"
            ],
            options: [
                DecisionOption(
                    id: 4,
                    title: "Mediación internacional neutral",
                    description: "Ofrecer servicios de mediación y proponer arbitraje en tribunales internacionales.",
                    approach: .diplomatic,
                    icon: "scale.3d",
                    consequences: ["Solución duradera", "Proceso complejo"],
                    skillsAwarded: ["Mediación", "Derecho marítimo", "Resolución de conflictos"]
                ),
                DecisionOption(
                    id: 5,
                    title: "Desarrollo conjunto de recursos",
                    description: "Proponer una zona económica especial administrada conjuntamente.",
                    approach: .economic,
                    icon: "leaf.arrow.circlepath",
                    consequences: ["Beneficio mutuo", "Complejidad administrativa"],
                    skillsAwarded: ["Innovación diplomática", "Cooperación económica", "Visión estratégica"]
                ),
                DecisionOption(
                    id: 6,
                    title: "Patrullaje internacional conjunto",
                    description: "Establecer una fuerza naval multinacional para mantener la paz en la zona.",
                    approach: .military,
                    icon: "shield.fill",
                    consequences: ["Estabilidad inmediata", "Costos altos"],
                    skillsAwarded: ["Seguridad internacional", "Logística militar", "Coordinación multinacional"]
                )
            ]
        )
    ]
    
    var hasMoreScenarios: Bool {
        currentCrisisIndex < crises.count - 1
    }
    
    func startGame() {
        gameState = .intro
        currentStep = 0
    }
    
    func nextStep() {
        currentStep += 1
        
        switch gameState {
        case .intro:
            gameState = .scenario
        case .scenario:
            gameState = .decision
            loadCurrentCrisis()
        case .decision:
            gameState = .result
        case .result:
            if hasMoreScenarios {
                currentCrisisIndex += 1
                gameState = .decision
                loadCurrentCrisis()
                selectedOption = nil
            } else {
                gameState = .final
                calculateFinalScores()
            }
        case .final:
            break
        }
    }
    
    func selectCountry(_ country: Country) {
        selectedCountry = country
    }
    
    func selectOption(_ option: DecisionOption) {
        selectedOption = option
    }
    
    func submitDecision() {
        guard let option = selectedOption else { return }
        decisions.append(option)
        generateResult(for: option)
        nextStep()
    }
    
    private func loadCurrentCrisis() {
        guard currentCrisisIndex < crises.count else { return }
        currentCrisis = crises[currentCrisisIndex]
    }
    
    private func generateResult(for option: DecisionOption) {
        let outcomes = [
            // Diplomatic outcomes
            (approach: Approach.diplomatic, positive: true,
             title: "¡Negociación Exitosa!",
             description: "Tu enfoque diplomático logró un consenso que beneficia a todas las partes involucradas."),
            (approach: Approach.diplomatic, positive: false,
             title: "Proceso Complejo",
             description: "Aunque el diálogo continúa, se necesita más tiempo para alcanzar un acuerdo definitivo."),
            
            // Economic outcomes
            (approach: Approach.economic, positive: true,
             title: "Estrategia Económica Efectiva",
             description: "Las medidas económicas propuestas generaron presión suficiente para motivar el cambio."),
            (approach: Approach.economic, positive: false,
             title: "Resistencia Económica",
             description: "Las partes mostraron mayor resistencia de la esperada a las presiones económicas."),
            
            // Military outcomes
            (approach: Approach.military, positive: true,
             title: "Estabilización Lograda",
             description: "La presencia de fuerzas internacionales logró reducir las tensiones inmediatamente."),
            (approach: Approach.military, positive: false,
             title: "Escalación Controlada",
             description: "La respuesta militar evitó el peor escenario, pero las tensiones persisten."),
            
            // Humanitarian outcomes
            (approach: Approach.humanitarian, positive: true,
             title: "Vidas Salvadas",
             description: "Tu enfoque humanitario logró proteger a los civiles y facilitar la ayuda necesaria."),
            (approach: Approach.humanitarian, positive: false,
             title: "Acceso Limitado",
             description: "Se logró ayuda parcial, pero persisten obstáculos para la asistencia completa.")
        ]
        
        let relevantOutcomes = outcomes.filter { $0.approach == option.approach }
        let selectedOutcome = relevantOutcomes.randomElement() ?? outcomes[0]
        
        lastResult = DecisionResult(
            title: selectedOutcome.title,
            description: selectedOutcome.description,
            isPositive: selectedOutcome.positive,
            skillsGained: option.skillsAwarded
        )
    }
    
    private func calculateFinalScores() {
        var internationalRelations: Double = 0
        var leadership: Double = 0
        var law: Double = 0
        var communication: Double = 0
        
        for decision in decisions {
            switch decision.approach {
            case .diplomatic:
                internationalRelations += 0.3
                communication += 0.25
                law += 0.2
            case .economic:
                leadership += 0.25
                internationalRelations += 0.2
                communication += 0.15
            case .military:
                leadership += 0.3
                law += 0.15
                internationalRelations += 0.1
            case .humanitarian:
                communication += 0.3
                internationalRelations += 0.25
                leadership += 0.2
            }
        }
        
        // Normalize scores and add base values
        internationalRelations = min(1.0, 0.4 + internationalRelations)
        leadership = min(1.0, 0.3 + leadership)
        law = min(1.0, 0.35 + law)
        communication = min(1.0, 0.25 + communication)
        
        finalScores = FinalScores(
            internationalRelations: internationalRelations,
            leadership: leadership,
            law: law,
            communication: communication
        )
    }
    
    func updateUserProfile() {
        // TODO: Update user's vocational profile with new scores
        // This would integrate with your ProfileViewModel
        print("Updating user profile with new scores:")
        print("International Relations: \(finalScores.internationalRelations)")
        print("Leadership: \(finalScores.leadership)")
        print("Law: \(finalScores.law)")
        print("Communication: \(finalScores.communication)")
    }
    
    func restartGame() {
        gameState = .intro
        currentStep = 0
        currentCrisisIndex = 0
        decisions.removeAll()
        selectedOption = nil
        selectedCountry = Country(name: "Selecciona", flag: "🌍", region: "", characteristics: [])
    }
}

enum GameState {
    case intro
    case scenario
    case decision
    case result
    case final
}

#Preview {
    MUNGameView()
}
