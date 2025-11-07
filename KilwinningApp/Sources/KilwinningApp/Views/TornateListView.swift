import SwiftUI

struct TornateListView: View {
    @StateObject private var dataService = DataService.shared
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedType: TornataType?
    @State private var showingAddTornata = false
    
    var filteredTornate: [Tornata] {
        dataService.tornate
            .filter { tornata in
                let yearMatches = Calendar.current.component(.year, from: tornata.date) == selectedYear
                let typeMatches = selectedType == nil || tornata.type == selectedType
                return yearMatches && typeMatches
            }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header con filtri
            HStack {
                Text("Tornate")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                // Filtro anno
                Menu {
                    ForEach(2020...2030, id: \.self) { year in
                        Button(String(year)) {
                            selectedYear = year
                        }
                    }
                } label: {
                    HStack {
                        Text(String(selectedYear))
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.masonicBlue.opacity(0.1))
                    .foregroundColor(AppTheme.masonicBlue)
                    .cornerRadius(8)
                }
                
                // Filtro tipo
                Menu {
                    Button("Tutte") {
                        selectedType = nil
                    }
                    ForEach(TornataType.allCases, id: \.self) { type in
                        Button(type.rawValue) {
                            selectedType = type
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedType?.rawValue ?? "Tutte")
                        Image(systemName: "chevron.down")
                    }
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.masonicBlue.opacity(0.1))
                    .foregroundColor(AppTheme.masonicBlue)
                    .cornerRadius(8)
                }
            }
            
            // Lista tornate
            if filteredTornate.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    message: "Nessuna tornata trovata"
                )
                .padding()
                .cardStyle()
            } else {
                ForEach(filteredTornate) { tornata in
                    TornataListRow(tornata: tornata)
                }
            }
        }
    }
}

struct TornataListRow: View {
    let tornata: Tornata
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var dataService = DataService.shared
    @State private var showingDetails = false
    
    var presenceStatus: PresenceStatus {
        guard let brother = authService.currentBrother else { return .nonConfermato }
        return dataService.getPresenceStatus(brotherId: brother.id, tornataId: tornata.id)
    }
    
    var body: some View {
        Button(action: { showingDetails = true }) {
            HStack(alignment: .top, spacing: 12) {
                // Data
                VStack {
                    Text(tornata.date.formatted(.dateTime.day()))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.masonicBlue)
                    
                    Text(tornata.date.formatted(.dateTime.month(.abbreviated)))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(width: 50)
                
                // Dettagli
                VStack(alignment: .leading, spacing: 6) {
                    Text(tornata.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Label(tornata.type.rawValue, systemImage: tornata.type == .cerimonia ? "star.fill" : "calendar")
                            .font(.caption)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        Text("•")
                            .foregroundColor(.gray)
                        
                        Text(tornata.location.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text("Introduce: \(tornata.introducedBy)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Stato presenza
                PresenceStatusBadge(status: presenceStatus)
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetails) {
            TornataDetailView(tornata: tornata)
        }
    }
}

struct TornataDetailView: View {
    @Environment(\.dismiss) var dismiss
    let tornata: Tornata
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Titolo e data
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tornata.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        Text(tornata.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    // Dettagli completi
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(icon: "star.fill", label: "Tipo", value: tornata.type.rawValue)
                        DetailRow(icon: "person.fill", label: "Introduce", value: tornata.introducedBy)
                        DetailRow(icon: "mappin.circle.fill", label: "Luogo", value: tornata.location.rawValue)
                        
                        if tornata.hasDinner {
                            DetailRow(icon: "fork.knife", label: "Cena", value: "Prevista")
                        }
                        
                        if let notes = tornata.notes {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Note")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(notes)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            .navigationBarItems(trailing: Button("Chiudi") {
                dismiss()
            })
        }
    }
}

#Preview {
    TornateListView()
}
