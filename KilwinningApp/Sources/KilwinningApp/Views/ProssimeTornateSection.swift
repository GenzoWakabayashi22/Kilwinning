import SwiftUI

struct ProssimeTornateSection: View {
    let brother: Brother
    @StateObject private var dataService = DataService.shared
    
    var upcomingTornate: [Tornata] {
        let now = Date()
        return dataService.tornate
            .filter { $0.date > now }
            .sorted { $0.date < $1.date }
    }
    
    var totalBrothers: Int {
        25 // TODO: Prendere dal database
    }
    
    var totalPresent: Int {
        // TODO: Calcolare dal database
        upcomingTornate.first.map { tornata in
            dataService.presences.filter { 
                $0.tornataId == tornata.id && $0.status == .presente 
            }.count
        } ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Prossime Tornate")
                .sectionHeaderStyle()
            
            if upcomingTornate.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    message: "Nessuna tornata programmata"
                )
                .padding()
                .cardStyle()
            } else {
                ForEach(upcomingTornate) { tornata in
                    TornataDetailCard(tornata: tornata, brother: brother)
                }
                
                // Riepilogo partecipazione
                if let firstTornata = upcomingTornate.first {
                    ParticipationSummaryCard(
                        totalPresent: totalPresent,
                        totalBrothers: totalBrothers
                    )
                }
            }
        }
    }
}

struct TornataDetailCard: View {
    let tornata: Tornata
    let brother: Brother
    @StateObject private var dataService = DataService.shared
    
    @State private var selectedStatus: PresenceStatus
    
    init(tornata: Tornata, brother: Brother) {
        self.tornata = tornata
        self.brother = brother
        _selectedStatus = State(initialValue: DataService.shared.getPresenceStatus(
            brotherId: brother.id,
            tornataId: tornata.id
        ))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Titolo e data
            VStack(alignment: .leading, spacing: 4) {
                Text(tornata.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Text(tornata.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Divider()
            
            // Dettagli
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(icon: "star.fill", label: "Tipo", value: tornata.type.rawValue)
                DetailRow(icon: "person.fill", label: "Introduce", value: tornata.introducedBy)
                DetailRow(icon: "mappin.circle.fill", label: "Luogo", value: tornata.location.rawValue)
                
                if tornata.hasDinner {
                    DetailRow(icon: "fork.knife", label: "Cena", value: "Prevista")
                }
            }
            
            Divider()
            
            // Selezione presenza
            VStack(alignment: .leading, spacing: 8) {
                Text("La tua partecipazione")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    ActionButton(
                        title: "Presente",
                        icon: "checkmark.circle.fill",
                        isSelected: selectedStatus == .presente,
                        color: AppTheme.success
                    ) {
                        updatePresence(.presente)
                    }
                    
                    ActionButton(
                        title: "Assente",
                        icon: "xmark.circle.fill",
                        isSelected: selectedStatus == .assente,
                        color: AppTheme.error
                    ) {
                        updatePresence(.assente)
                    }
                }
            }
            
            if selectedStatus != .nonConfermato {
                Text("✓ Confermato")
                    .font(.caption)
                    .foregroundColor(AppTheme.success)
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func updatePresence(_ status: PresenceStatus) {
        selectedStatus = status
        Task {
            await dataService.updatePresence(
                brotherId: brother.id,
                tornataId: tornata.id,
                status: status
            )
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// ActionButton and EmptyStateView moved to Utilities/CommonViews.swift to avoid duplication

struct ParticipationSummaryCard: View {
    let totalPresent: Int
    let totalBrothers: Int
    
    var percentage: Double {
        totalBrothers > 0 ? Double(totalPresent) / Double(totalBrothers) * 100 : 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Riepilogo Partecipazione")
                    .font(.headline)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Text("Totale presenti: \(totalPresent) su \(totalBrothers)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(String(format: "%.0f%%", percentage))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.masonicGold)
        }
        .padding()
        .cardStyle()
    }
}

// EmptyStateView moved to Utilities/CommonViews.swift to avoid duplication

#Preview {
    ProssimeTornateSection(brother: Brother(
        firstName: "Paolo Giulio",
        lastName: "Gazzano",
        email: "demo@kilwinning.it",
        degree: .maestro,
        role: .venerabileMaestro,
        isAdmin: true
    ))
}
