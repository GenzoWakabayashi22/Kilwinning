import SwiftUI

struct TornateListView: View {
    @StateObject private var dataService = DataService()
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
            
            // Lista tornate con loading state
            if dataService.isLoading {
                VStack {
                    ProgressView("Caricamento tornate...")
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.masonicBlue))
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .cardStyle()
            } else if let errorMessage = dataService.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)

                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        Task {
                            await dataService.fetchTornate()
                        }
                    }) {
                        Label("Riprova", systemImage: "arrow.clockwise")
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.masonicBlue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .cardStyle()
            } else if filteredTornate.isEmpty {
                EmptyStateView(
                    icon: "calendar.badge.exclamationmark",
                    message: "Nessuna tornata trovata"
                )
                .padding()
                .cardStyle()
            } else {
                ForEach(filteredTornate) { tornata in
                    TornataListRow(tornata: tornata, dataService: dataService)
                }
            }
        }
        .task {
            // Carica le tornate all'avvio della view
            await dataService.fetchTornate()
        }
    }
}

struct TornataListRow: View {
    let tornata: Tornata
    @ObservedObject var dataService: DataService
    @EnvironmentObject var authService: AuthenticationService
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
            if let brother = authService.currentBrother {
                TornataDetailView(tornata: tornata, brother: brother)
            } else {
                // Fallback se l'utente non è autenticato
                Text("Errore: utente non autenticato")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
}

#Preview {
    TornateListView()
}
