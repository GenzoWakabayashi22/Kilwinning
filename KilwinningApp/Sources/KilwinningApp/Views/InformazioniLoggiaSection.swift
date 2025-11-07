import SwiftUI

struct InformazioniLoggiaSection: View {
    @StateObject private var dataService = DataService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Informazioni Loggia")
                .sectionHeaderStyle()
            
            VStack(spacing: 15) {
                // Sede
                InfoCard(
                    title: "Sede",
                    icon: "mappin.and.ellipse",
                    content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Via XX Settembre 22")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("Tolfa (RM)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                )
                
                // Calendario
                InfoCard(
                    title: "Calendario Tornate",
                    icon: "calendar",
                    content: {
                        VStack(alignment: .leading, spacing: 6) {
                            InfoRow(label: "Secondo martedì del mese", showBullet: true)
                            InfoRow(label: "Quarto giovedì del mese", showBullet: true)
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(AppTheme.masonicBlue)
                                Text("Inizio lavori: 19:30")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppTheme.warning)
                                Text("Conferme entro 5 giorni prima")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                )
                
                // Statistiche Loggia
                InfoCard(
                    title: "Statistiche Loggia",
                    icon: "chart.bar.fill",
                    content: {
                        VStack(spacing: 8) {
                            StatisticRow(
                                label: "Fratelli registrati",
                                value: "25",
                                icon: "person.3.fill"
                            )
                            
                            StatisticRow(
                                label: "Cariche istituzionali",
                                value: "11",
                                icon: "star.fill"
                            )
                            
                            StatisticRow(
                                label: "Presenza media annuale",
                                value: "85%",
                                icon: "chart.line.uptrend.xyaxis"
                            )
                            
                            StatisticRow(
                                label: "Partecipazione loggia 2025",
                                value: "92%",
                                icon: "checkmark.seal.fill"
                            )
                        }
                    }
                )
            }
        }
    }
}

struct InfoCard<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(AppTheme.masonicGold)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppTheme.masonicBlue)
            }
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .cardStyle()
    }
}

// InfoRow moved to Utilities/CommonViews.swift to avoid duplication

struct StatisticRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.masonicBlue)
                .frame(width: 24)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.masonicGold)
        }
    }
}

#Preview {
    InformazioniLoggiaSection()
}
