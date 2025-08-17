import SwiftUI

struct DesignLabGameView: View {
    @StateObject private var gameViewModel = DesignLabViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Artistic gradient background
            LinearGradient(
                colors: [.pink.opacity(0.8), .purple.opacity(0.6), .blue.opacity(0.4), .mint.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main content based on game state
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 20) {
                            switch gameViewModel.gameState {
                            case .intro:
                                introView
                            case .briefing:
                                briefingView
                            case .challenge:
                                challengeView
                            case .creation:
                                creationView
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
            gameViewModel.startGame()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button("← Salir") {
                dismiss()
            }
            .font(.callout)
            .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            // Progress with artistic dots
            HStack(spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(index <= gameViewModel.currentStep ?
                              LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing) :
                              LinearGradient(colors: [.white.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: 12, height: 12)
                        .scaleEffect(index == gameViewModel.currentStep ? 1.2 : 1.0)
                        .animation(.bouncy, value: gameViewModel.currentStep)
                }
            }
            
            Spacer()
            
            // Creativity meter
            VStack(spacing: 2) {
                Text("🎨")
                    .font(.title3)
                
                Text("\(gameViewModel.creativityPoints)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
            )
        }
        .padding()
        .background(Color.black.opacity(0.1))
    }
    
    // MARK: - Intro View
    private var introView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                // Animated art palette icon
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.pink, .purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 120, height: 120)
                        .shadow(color: .purple.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(gameViewModel.isAnimating ? 360 : 0))
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: gameViewModel.isAnimating)
                }
                
                VStack(spacing: 12) {
                    Text("🎨 Design Lab")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                    
                    Text("Laboratorio de Creatividad")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text("Descubre tu potencial creativo a través de desafíos de diseño")
                        .font(.callout)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            VStack(spacing: 20) {
                LabFeatureCard(
                    icon: "lightbulb.fill",
                    title: "Desafíos Creativos",
                    description: "Resuelve problemas de diseño real",
                    color: .yellow
                )
                
                LabFeatureCard(
                    icon: "eye.fill",
                    title: "Percepción Visual",
                    description: "Desarrolla tu ojo artístico",
                    color: .blue
                )
                
                LabFeatureCard(
                    icon: "paintbrush.pointed.fill",
                    title: "Herramientas Digitales",
                    description: "Experimenta con técnicas de diseño",
                    color: .purple
                )
            }
            
            Button("🚀 Entrar al Lab") {
                gameViewModel.nextStep()
            }
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [.pink, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
            .padding(.top, 20)
        }
    }
    
    // MARK: - Briefing View
    private var briefingView: some View {
        VStack(spacing: 25) {
            VStack(spacing: 16) {
                Text("📋 Tu Primera Misión")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Elige tu especialidad de diseño")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(gameViewModel.designSpecialties, id: \.name) { specialty in
                    DesignSpecialtyCard(
                        specialty: specialty,
                        isSelected: gameViewModel.selectedSpecialty?.name == specialty.name
                    ) {
                        gameViewModel.selectSpecialty(specialty)
                    }
                }
            }
            
            if gameViewModel.selectedSpecialty != nil {
                VStack(spacing: 16) {
                    SpecialtyDetailCard(specialty: gameViewModel.selectedSpecialty!)
                    
                    Button("Comenzar Desafío 🎯") {
                        gameViewModel.nextStep()
                    }
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        LinearGradient(
                            colors: [gameViewModel.selectedSpecialty!.primaryColor, gameViewModel.selectedSpecialty!.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(radius: 4)
                }
            }
        }
    }
    
    // MARK: - Challenge View
    private var challengeView: some View {
        VStack(spacing: 25) {
            // Challenge brief
            ChallengeCard(challenge: gameViewModel.currentChallenge)
            
            // Tools selection
            VStack(spacing: 16) {
                Text("🛠️ Elige tus herramientas")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(gameViewModel.availableTools, id: \.name) { tool in
                        ToolCard(
                            tool: tool,
                            isSelected: gameViewModel.selectedTools.contains { $0.name == tool.name }
                        ) {
                            gameViewModel.toggleTool(tool)
                        }
                    }
                }
            }
            
            // Style selection
            VStack(spacing: 16) {
                Text("✨ Selecciona el estilo")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(gameViewModel.availableStyles, id: \.name) { style in
                            StyleCard(
                                style: style,
                                isSelected: gameViewModel.selectedStyle?.name == style.name
                            ) {
                                gameViewModel.selectStyle(style)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            if !gameViewModel.selectedTools.isEmpty && gameViewModel.selectedStyle != nil {
                Button("Crear Diseño 🎨") {
                    gameViewModel.nextStep()
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
    
    // MARK: - Creation View
    private var creationView: some View {
        VStack(spacing: 25) {
            VStack(spacing: 16) {
                Text("🎨 ¡Creando tu diseño!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text("Observa cómo cobran vida tus decisiones...")
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // Creative process visualization
            VStack(spacing: 20) {
                CreationStepCard(
                    step: "Conceptualización",
                    description: "Definiendo la idea principal",
                    isActive: gameViewModel.creationStep >= 1,
                    isComplete: gameViewModel.creationStep > 1,
                    color: .blue
                )
                
                CreationStepCard(
                    step: "Bocetado",
                    description: "Creando los primeros trazos",
                    isActive: gameViewModel.creationStep >= 2,
                    isComplete: gameViewModel.creationStep > 2,
                    color: .purple
                )
                
                CreationStepCard(
                    step: "Diseño Digital",
                    description: "Utilizando herramientas digitales",
                    isActive: gameViewModel.creationStep >= 3,
                    isComplete: gameViewModel.creationStep > 3,
                    color: .pink
                )
                
                CreationStepCard(
                    step: "Refinamiento",
                    description: "Puliendo los detalles finales",
                    isActive: gameViewModel.creationStep >= 4,
                    isComplete: gameViewModel.creationStep > 4,
                    color: .orange
                )
            }
            
            // Simulated design canvas
            if gameViewModel.creationStep > 2 {
                DesignCanvasView(
                    specialty: gameViewModel.selectedSpecialty!,
                    style: gameViewModel.selectedStyle!,
                    tools: gameViewModel.selectedTools,
                    progress: gameViewModel.creationProgress
                )
            }
            
            if gameViewModel.creationStep >= 4 {
                Button("Ver Resultado Final 🌟") {
                    gameViewModel.nextStep()
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
            }
        }
    }
    
    // MARK: - Result View
    private var resultView: some View {
        VStack(spacing: 25) {
            // Design showcase
            VStack(spacing: 16) {
                Text("✨ ¡Tu Creación!")
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                FinalDesignShowcase(
                    specialty: gameViewModel.selectedSpecialty!,
                    style: gameViewModel.selectedStyle!,
                    rating: gameViewModel.designRating
                )
            }
            
            // Feedback and skills
            VStack(spacing: 16) {
                DesignFeedbackCard(feedback: gameViewModel.designFeedback)
                
                VStack(spacing: 12) {
                    Text("🎯 Habilidades Demostradas")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(gameViewModel.skillsGained, id: \.self) { skill in
                            SkillBadgeView(skill: skill)
                        }
                    }
                }
            }
            
            // Continue button
            Button(gameViewModel.hasMoreChallenges ? "Siguiente Desafío 🎨" : "Ver Perfil Creativo 🏆") {
                gameViewModel.nextStep()
            }
            .font(.headline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    colors: [.purple, .blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(radius: 4)
        }
    }
    
    // MARK: - Final Results View
    private var finalResultsView: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 100, height: 100)
                        .shadow(color: .orange.opacity(0.3), radius: 20)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                Text("🎨 ¡Lab Completado!")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Tu Perfil Creativo")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            // Creative insights
            VStack(spacing: 20) {
                CreativeInsightCard(
                    icon: "paintpalette.fill",
                    title: "Diseño Visual",
                    compatibility: gameViewModel.finalScores.visualDesign,
                    description: "Tu habilidad para crear composiciones atractivas"
                )
                
                CreativeInsightCard(
                    icon: "lightbulb.fill",
                    title: "Pensamiento Creativo",
                    compatibility: gameViewModel.finalScores.creativity,
                    description: "Capacidad para generar ideas innovadoras"
                )
                
                CreativeInsightCard(
                    icon: "eye.fill",
                    title: "Sensibilidad Estética",
                    compatibility: gameViewModel.finalScores.aestheticSense,
                    description: "Percepción visual y sentido del color"
                )
                
                CreativeInsightCard(
                    icon: "gear",
                    title: "Dominio Técnico",
                    compatibility: gameViewModel.finalScores.technicalSkills,
                    description: "Manejo de herramientas y técnicas de diseño"
                )
            }
            
            // Action buttons
            VStack(spacing: 12) {
                Button("Actualizar Mi Perfil 📈") {
                    gameViewModel.updateUserProfile()
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
                
                Button("Explorar Más Desafíos 🔄") {
                    gameViewModel.restartGame()
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

struct LabFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
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

struct DesignSpecialtyCard: View {
    let specialty: DesignSpecialty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [specialty.primaryColor, specialty.secondaryColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 60, height: 60)
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.bouncy, value: isSelected)
                    
                    Image(systemName: specialty.icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 4) {
                    Text(specialty.name)
                        .font(.callout.bold())
                        .foregroundColor(.white)
                    
                    Text(specialty.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
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

struct SpecialtyDetailCard: View {
    let specialty: DesignSpecialty
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: specialty.icon)
                    .font(.title2)
                    .foregroundColor(specialty.primaryColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(specialty.name)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    Text("Especialidad seleccionada")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Enfoques principales:")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                ForEach(specialty.keyAreas, id: \.self) { area in
                    HStack {
                        Circle()
                            .fill(specialty.primaryColor)
                            .frame(width: 6, height: 6)
                        Text(area)
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

struct ChallengeCard: View {
    let challenge: DesignChallenge
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("DESAFÍO CREATIVO")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    
                    Text(challenge.title)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            Text(challenge.description)
                .font(.callout)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Requisitos:")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                ForEach(challenge.requirements, id: \.self) { requirement in
                    HStack(alignment: .top) {
                        Text("•")
                            .foregroundColor(.white.opacity(0.6))
                        Text(requirement)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
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
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ToolCard: View {
    let tool: DesignTool
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: tool.icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                Text(tool.name)
                    .font(.caption2.bold())
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? tool.color.opacity(0.3) : Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? tool.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

struct StyleCard: View {
    let style: DesignStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(style.emoji)
                    .font(.title)
                
                Text(style.name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                
                Text(style.description)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(width: 120)
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

struct CreationStepCard: View {
    let step: String
    let description: String
    let isActive: Bool
    let isComplete: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isComplete ? .green : (isActive ? color : Color.white.opacity(0.3)))
                    .frame(width: 40, height: 40)
                
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                } else if isActive {
                    Circle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isActive ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isActive)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step)
                    .font(.callout.bold())
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .opacity(isActive || isComplete ? 1.0 : 0.5)
        .animation(.easeInOut, value: isActive)
    }
}

struct DesignCanvasView: View {
    let specialty: DesignSpecialty
    let style: DesignStyle
    let tools: [DesignTool]
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🖥️ Canvas Digital")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.9), .white.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 200)
                
                VStack(spacing: 12) {
                    Text(style.emoji)
                        .font(.system(size: 60))
                        .opacity(progress)
                    
                    Text("Creando \(specialty.name)")
                        .font(.callout.bold())
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("Estilo: \(style.name)")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.5))
                    
                    HStack {
                        ForEach(tools.prefix(3), id: \.name) { tool in
                            Image(systemName: tool.icon)
                                .foregroundColor(tool.color)
                        }
                    }
                }
                .scaleEffect(0.3 + (progress * 0.7))
                .animation(.easeInOut(duration: 0.8), value: progress)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            colors: [specialty.primaryColor, specialty.secondaryColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut(duration: 0.8), value: progress)
                }
            }
            .frame(height: 8)
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

struct FinalDesignShowcase: View {
    let specialty: DesignSpecialty
    let style: DesignStyle
    let rating: Int
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.95), .white.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(height: 250)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 16) {
                    Text(style.emoji)
                        .font(.system(size: 80))
                    
                    Text("Diseño \(specialty.name)")
                        .font(.title2.bold())
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text("Estilo: \(style.name)")
                        .font(.callout)
                        .foregroundColor(.black.opacity(0.6))
                    
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < rating ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundColor(index < rating ? .yellow : .gray.opacity(0.3))
                        }
                    }
                    
                    Text("\(rating)/5 estrellas")
                        .font(.caption.bold())
                        .foregroundColor(.black.opacity(0.7))
                }
            }
        }
    }
}

struct DesignFeedbackCard: View {
    let feedback: DesignFeedback
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Feedback del Jurado")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(feedback.comment)
                    .font(.callout)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("Fortalezas:")
                        .font(.caption.bold())
                        .foregroundColor(.green)
                    
                    Text(feedback.strengths.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
                
                HStack {
                    Text("Mejoras:")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                    
                    Text(feedback.improvements.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
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

struct SkillBadgeView: View {
    let skill: String
    
    var body: some View {
        Text(skill)
            .font(.caption.bold())
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(
                        colors: [.purple.opacity(0.4), .pink.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                    )
            )
    }
}

struct CreativeInsightCard: View {
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
                    
                    Text("Afinidad")
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
                            colors: [.pink, .purple],
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

struct DesignSpecialty {
    let name: String
    let description: String
    let icon: String
    let primaryColor: Color
    let secondaryColor: Color
    let keyAreas: [String]
}

struct DesignChallenge {
    let title: String
    let description: String
    let requirements: [String]
}

struct DesignTool {
    let name: String
    let icon: String
    let color: Color
    let skillBonus: String
}

struct DesignStyle {
    let name: String
    let description: String
    let emoji: String
}

struct DesignFeedback {
    let comment: String
    let strengths: [String]
    let improvements: [String]
}

struct CreativeScores {
    let visualDesign: Double
    let creativity: Double
    let aestheticSense: Double
    let technicalSkills: Double
}

// MARK: - ViewModel

@MainActor
class DesignLabViewModel: ObservableObject {
    @Published var gameState: DesignGameState = .intro
    @Published var currentStep: Int = 0
    @Published var creativityPoints: Int = 0
    @Published var isAnimating: Bool = false
    
    @Published var selectedSpecialty: DesignSpecialty?
    @Published var selectedTools: [DesignTool] = []
    @Published var selectedStyle: DesignStyle?
    
    @Published var currentChallenge: DesignChallenge = DesignChallenge(title: "", description: "", requirements: [])
    @Published var creationStep: Int = 0
    @Published var creationProgress: Double = 0.0
    @Published var designRating: Int = 0
    @Published var designFeedback: DesignFeedback = DesignFeedback(comment: "", strengths: [], improvements: [])
    @Published var skillsGained: [String] = []
    @Published var finalScores: CreativeScores = CreativeScores(visualDesign: 0, creativity: 0, aestheticSense: 0, technicalSkills: 0)
    
    private var currentChallengeIndex = 0
    private var completedChallenges: [DesignChallenge] = []
    
    let designSpecialties = [
        DesignSpecialty(
            name: "Diseño Gráfico",
            description: "Comunicación visual",
            icon: "paintbrush.fill",
            primaryColor: .purple,
            secondaryColor: .pink,
            keyAreas: ["Branding", "Editorial", "Publicidad", "Identidad visual"]
        ),
        DesignSpecialty(
            name: "UX/UI Design",
            description: "Experiencias digitales",
            icon: "iphone",
            primaryColor: .blue,
            secondaryColor: .mint,
            keyAreas: ["Interfaces", "Prototipos", "Usabilidad", "Interacción"]
        ),
        DesignSpecialty(
            name: "Diseño de Producto",
            description: "Objetos funcionales",
            icon: "cube.fill",
            primaryColor: .orange,
            secondaryColor: .yellow,
            keyAreas: ["Ergonomía", "Materiales", "Fabricación", "Innovación"]
        ),
        DesignSpecialty(
            name: "Diseño Editorial",
            description: "Medios impresos",
            icon: "book.fill",
            primaryColor: .green,
            secondaryColor: .mint,
            keyAreas: ["Tipografía", "Layout", "Revistas", "Libros"]
        )
    ]
    
    let availableTools = [
        DesignTool(name: "Photoshop", icon: "photo.fill", color: .blue, skillBonus: "Edición"),
        DesignTool(name: "Illustrator", icon: "pencil.tip.crop.circle.fill", color: .orange, skillBonus: "Vectores"),
        DesignTool(name: "Figma", icon: "rectangle.3.group.fill", color: .purple, skillBonus: "Prototipos"),
        DesignTool(name: "Sketch", icon: "scribble.variable", color: .pink, skillBonus: "UI"),
        DesignTool(name: "InDesign", icon: "doc.text.fill", color: .red, skillBonus: "Editorial"),
        DesignTool(name: "Procreate", icon: "paintbrush.pointed.fill", color: .green, skillBonus: "Digital Art")
    ]
    
    let availableStyles = [
        DesignStyle(name: "Minimalista", description: "Limpio y simple", emoji: "⚪"),
        DesignStyle(name: "Vintage", description: "Retro y nostálgico", emoji: "📻"),
        DesignStyle(name: "Moderno", description: "Contemporáneo", emoji: "🔷"),
        DesignStyle(name: "Orgánico", description: "Natural y fluido", emoji: "🌿"),
        DesignStyle(name: "Geométrico", description: "Formas definidas", emoji: "🔸"),
        DesignStyle(name: "Artístico", description: "Expresivo y libre", emoji: "🎨")
    ]
    
    private let challenges = [
        DesignChallenge(
            title: "Identidad Visual para Startup",
            description: "Una startup de tecnología verde necesita una identidad visual que transmita innovación y sustentabilidad.",
            requirements: [
                "Logo principal y variaciones",
                "Paleta de colores ecológica",
                "Tipografía moderna",
                "Aplicaciones en diferentes medios"
            ]
        ),
        DesignChallenge(
            title: "App de Bienestar Mental",
            description: "Diseña la interfaz de una aplicación móvil para meditación y mindfulness.",
            requirements: [
                "Pantalla de bienvenida tranquila",
                "Navegación intuitiva",
                "Colores relajantes",
                "Iconografía minimalista"
            ]
        )
    ]
    
    var hasMoreChallenges: Bool {
        currentChallengeIndex < challenges.count - 1
    }
    
    func startGame() {
        gameState = .intro
        currentStep = 0
        creativityPoints = 0
        isAnimating = true
    }
    
    func nextStep() {
        currentStep += 1
        
        switch gameState {
        case .intro:
            gameState = .briefing
        case .briefing:
            gameState = .challenge
            loadCurrentChallenge()
        case .challenge:
            gameState = .creation
            startCreationProcess()
        case .creation:
            gameState = .result
            generateResult()
        case .result:
            if hasMoreChallenges {
                currentChallengeIndex += 1
                gameState = .challenge
                loadCurrentChallenge()
                resetSelections()
            } else {
                gameState = .final
                calculateFinalScores()
            }
        case .final:
            break
        }
    }
    
    func selectSpecialty(_ specialty: DesignSpecialty) {
        selectedSpecialty = specialty
        creativityPoints += 10
    }
    
    func toggleTool(_ tool: DesignTool) {
        if selectedTools.contains(where: { $0.name == tool.name }) {
            selectedTools.removeAll { $0.name == tool.name }
            creativityPoints -= 5
        } else {
            selectedTools.append(tool)
            creativityPoints += 5
        }
    }
    
    func selectStyle(_ style: DesignStyle) {
        selectedStyle = style
        creativityPoints += 10
    }
    
    private func loadCurrentChallenge() {
        guard currentChallengeIndex < challenges.count else { return }
        currentChallenge = challenges[currentChallengeIndex]
    }
    
    private func startCreationProcess() {
        creationStep = 0
        creationProgress = 0.0
        
        // Simulate creation steps
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            DispatchQueue.main.async {
                if self.creationStep < 4 {
                    self.creationStep += 1
                    self.creationProgress = Double(self.creationStep) / 4.0
                } else {
                    timer.invalidate()
                }
            }
        }
    }
    
    private func generateResult() {
        // Calculate design rating based on choices
        var rating = 3 // Base rating
        
        if selectedTools.count >= 2 { rating += 1 }
        if selectedStyle != nil { rating += 1 }
        
        designRating = min(5, rating)
        creativityPoints += designRating * 10
        
        // Generate feedback
        let comments = [
            "¡Excelente trabajo! Tu diseño muestra una gran comprensión de los principios visuales.",
            "Buen uso de las herramientas digitales. El estilo elegido complementa perfectamente el briefing.",
            "Tu creatividad brilló en este proyecto. La solución es tanto funcional como estética.",
            "Impresionante atención al detalle. El resultado final supera las expectativas."
        ]
        
        let strengthOptions = ["Color", "Composición", "Tipografía", "Creatividad", "Técnica", "Conceptualización"]
        let improvementOptions = ["Contraste", "Jerarquía", "Consistencia", "Funcionalidad", "Innovación"]
        
        designFeedback = DesignFeedback(
            comment: comments.randomElement() ?? comments[0],
            strengths: Array(strengthOptions.shuffled().prefix(2)),
            improvements: Array(improvementOptions.shuffled().prefix(1))
        )
        
        // Skills gained based on specialty and tools
        var skills: [String] = []
        if let specialty = selectedSpecialty {
            skills.append(specialty.keyAreas.randomElement() ?? "Diseño")
        }
        skills += selectedTools.prefix(2).map { $0.skillBonus }
        
        skillsGained = skills
    }
    
    private func calculateFinalScores() {
        var visualDesign: Double = 0.4
        var creativity: Double = 0.3
        var aestheticSense: Double = 0.35
        var technicalSkills: Double = 0.25
        
        // Bonus based on specialty
        if let specialty = selectedSpecialty {
            switch specialty.name {
            case "Diseño Gráfico":
                visualDesign += 0.3
                aestheticSense += 0.25
            case "UX/UI Design":
                technicalSkills += 0.35
                creativity += 0.2
            case "Diseño de Producto":
                creativity += 0.3
                technicalSkills += 0.2
            case "Diseño Editorial":
                visualDesign += 0.25
                technicalSkills += 0.25
            default:
                break
            }
        }
        
        // Bonus for tools used
        let toolBonus = min(0.3, Double(selectedTools.count) * 0.05)
        technicalSkills += toolBonus
        
        // Bonus for creativity points
        let creativityBonus = min(0.2, Double(creativityPoints) / 500.0)
        creativity += creativityBonus
        
        // Normalize scores
        visualDesign = min(1.0, visualDesign)
        creativity = min(1.0, creativity)
        aestheticSense = min(1.0, aestheticSense)
        technicalSkills = min(1.0, technicalSkills)
        
        finalScores = CreativeScores(
            visualDesign: visualDesign,
            creativity: creativity,
            aestheticSense: aestheticSense,
            technicalSkills: technicalSkills
        )
    }
    
    private func resetSelections() {
        selectedTools.removeAll()
        selectedStyle = nil
    }
    
    func updateUserProfile() {
        // TODO: Update user's creative profile with new scores
        print("Updating user profile with creative scores:")
        print("Visual Design: \(finalScores.visualDesign)")
        print("Creativity: \(finalScores.creativity)")
        print("Aesthetic Sense: \(finalScores.aestheticSense)")
        print("Technical Skills: \(finalScores.technicalSkills)")
    }
    
    func restartGame() {
        gameState = .intro
        currentStep = 0
        currentChallengeIndex = 0
        creativityPoints = 0
        selectedSpecialty = nil
        selectedTools.removeAll()
        selectedStyle = nil
        skillsGained.removeAll()
        completedChallenges.removeAll()
    }
}

enum DesignGameState {
    case intro
    case briefing
    case challenge
    case creation
    case result
    case final
}

#Preview {
    DesignLabGameView()
}
