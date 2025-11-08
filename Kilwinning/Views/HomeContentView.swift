import SwiftUI

struct HomeContentView: View {
    let brother: Brother
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var libraryService: LibraryService
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Titolo Dashboard
                HStack {
                    Text("Dashboard")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Griglia principale 2x3
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    DashboardCard(
                        title: "Tornate",
                        icon: "calendar",
                        count: dataService.tornate.count,
                        gradient: AppTheme.tornateCardGradient,
                        destination: AnyView(TornateListView())
                    )
                    
                    DashboardCard(
                        title: "Presenze",
                        icon: "person.3.fill",
                        count: calculatePresenceCount(),
                        gradient: AppTheme.presenzeCardGradient,
                        destination: AnyView(PresenzeView(brother: brother))
                    )
                    
                    DashboardCard(
                        title: "Biblioteca",
                        icon: "books.vertical.fill",
                        count: libraryService.libri.count,
                        gradient: AppTheme.bibliotecaCardGradient,
                        destination: AnyView(BibliotecaView())
                    )
                    
                    DashboardCard(
                        title: "Tavole",
                        icon: "doc.text.fill",
                        count: dataService.tavole.count,
                        gradient: AppTheme.tavoleCardGradient,
                        destination: AnyView(TavoleView(brother: brother))
                    )
                    
                    DashboardCard(
                        title: "Statistiche",
                        icon: "chart.bar.fill",
                        count: nil,
                        gradient: AppTheme.statisticheCardGradient,
                        destination: AnyView(StatisticheView(brother: brother))
                    )
                    
                    DashboardCard(
                        title: "Rituali",
                        icon: "book.closed.fill",
                        count: nil,
                        gradient: AppTheme.ritualiCardGradient,
                        destination: AnyView(RitualiView())
                    )
                }
                .padding(.horizontal)
                
                // Sezione Prossime Tornate (rinnovata)
                ProssimeTornateSectionModern(brother: brother)
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppTheme.darkBackground.ignoresSafeArea())
    }
    
    private func calculatePresenceCount() -> Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        let stats = dataService.calculateStatistics(for: brother.id, year: currentYear)
        return stats.presences
    }
}

struct DashboardCard: View {
    let title: String
    let icon: String
    let count: Int?
    let gradient: LinearGradient
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let count = count {
                        Text("\(count)")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(20)
            .frame(height: 120)
            .background(gradient)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// Placeholder per la nuova vista Statistiche
struct StatisticheView: View {
    let brother: Brother
    
    var body: some View {
        Text("Statistiche View - Da implementare")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.darkBackground)
    }
}

// Placeholder per la nuova vista Rituali
struct RitualiView: View {
    var body: some View {
        Text("Rituali View - Da implementare")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.darkBackground)
    }
}

struct GradoRuoloCard: View {
    let brother: Brother
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "building.columns.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.masonicGold)
                
                Spacer()
            }
            
            Text("Grado e Ruolo")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            Text(brother.role != .none ? brother.role.rawValue : brother.degree.rawValue)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(brother.fullName)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

struct StatistichePresenzeCard: View {
    let brother: Brother
    @EnvironmentObject var dataService: DataService
    
    var statistics: PresenceStatistics {
        let currentYear = Calendar.current.component(.year, from: Date())
        return dataService.calculateStatistics(for: brother.id, year: currentYear)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
            }
            
            Text("Statistiche Presenze")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Presenze 2025: \(statistics.presences) su \(statistics.totalTornate)")
                    .font(.subheadline)
                
                if statistics.totalTornate > 0 {
                    Text("\(statistics.formattedAttendanceRate)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.masonicGold)
                }
                
                Text("Presenze consecutive: \(statistics.consecutivePresences)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                if statistics.personalRecord > 0 {
                    Text("Record personale: \(statistics.personalRecord)")
                        .font(.caption)
                        .foregroundColor(AppTheme.success)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

struct TornatePartecipateCard: View {
    let brother: Brother
    @EnvironmentObject var dataService: DataService
    
    var recentTornate: [Tornata] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return dataService.tornate
            .filter { Calendar.current.component(.year, from: $0.date) == currentYear }
            .sorted { $0.date > $1.date }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.title)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
            }
            
            Text("Tornate Partecipate")
                .font(.headline)
                .foregroundColor(AppTheme.masonicBlue)
            
            if recentTornate.isEmpty {
                Text("Nessuna tornata registrata")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recentTornate) { tornata in
                        TornataRowCompact(tornata: tornata, brother: brother)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

struct TornataRowCompact: View {
    let tornata: Tornata
    let brother: Brother
    @EnvironmentObject var dataService: DataService
    
    var presenceStatus: PresenceStatus {
        dataService.getPresenceStatus(brotherId: brother.id, tornataId: tornata.id)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tornata.shortDate)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(tornata.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 8) {
                    Label(tornata.type.rawValue, systemImage: tornata.type == .cerimonia ? "star.fill" : "calendar")
                        .font(.caption)
                        .foregroundColor(AppTheme.masonicBlue)
                    
                    Label(tornata.location.rawValue, systemImage: tornata.location.isHome ? "house.fill" : "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            PresenceStatusBadge(status: presenceStatus)
        }
        .padding(.vertical, 4)
    }
}

struct PresenceStatusBadge: View {
    let status: PresenceStatus
    
    var color: Color {
        switch status {
        case .presente: return AppTheme.success
        case .assente: return AppTheme.error
        case .nonConfermato: return AppTheme.warning
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
}

#Preview {
    HomeContentView(brother: Brother(
        firstName: "Paolo Giulio",
        lastName: "Gazzano",
        email: "demo@kilwinning.it",
        degree: .maestro,
        role: .venerabileMaestro,
        isAdmin: true
    ))
}
