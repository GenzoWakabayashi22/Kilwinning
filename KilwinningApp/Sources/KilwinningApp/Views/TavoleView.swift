import SwiftUI

struct TavoleView: View {
    let brother: Brother
    @StateObject private var dataService = DataService.shared
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var showingAddTavola = false
    
    var filteredTavole: [Tavola] {
        let brotherTavole = dataService.tavole.filter { $0.brotherId == brother.id }
        
        return brotherTavole.filter { tavola in
            if let date = tavola.presentationDate {
                return Calendar.current.component(.year, from: date) == selectedYear
            }
            return Calendar.current.component(.year, from: tavola.createdAt) == selectedYear
        }
        .sorted { ($0.presentationDate ?? $0.createdAt) > ($1.presentationDate ?? $1.createdAt) }
    }
    
    var yearlyCount: Int {
        filteredTavole.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Tavole Architettoniche")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                // Selettore anno
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
            }
            
            // Conteggio totale
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(AppTheme.masonicGold)
                
                Text("Totale tavole \(selectedYear): \(yearlyCount)")
                    .font(.headline)
                    .foregroundColor(AppTheme.masonicBlue)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .cardStyle()
            
            // Lista tavole
            if filteredTavole.isEmpty {
                EmptyStateView(
                    icon: "doc.text",
                    message: "Nessuna tavola registrata per quest'anno"
                )
                .padding()
                .cardStyle()
            } else {
                ForEach(filteredTavole) { tavola in
                    TavolaRow(tavola: tavola)
                }
            }
            
            // Pulsante aggiungi (se necessario in futuro)
            // Button(action: { showingAddTavola = true }) { ... }
        }
    }
}

struct TavolaRow: View {
    let tavola: Tavola
    @State private var showingDetail = false
    
    var statusColor: Color {
        switch tavola.status {
        case .completata: return AppTheme.success
        case .programmato: return AppTheme.warning
        case .inPreparazione: return AppTheme.masonicBlue
        }
    }
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            HStack(alignment: .top, spacing: 12) {
                // Icona stato
                Image(systemName: iconForStatus(tavola.status))
                    .font(.title2)
                    .foregroundColor(statusColor)
                    .frame(width: 40)
                
                // Contenuto
                VStack(alignment: .leading, spacing: 6) {
                    Text(tavola.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let date = tavola.formattedPresentationDate {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text("Trattata il: \(date)")
                                .font(.caption)
                        }
                        .foregroundColor(.gray)
                    } else {
                        Text("Data da definire")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Stato
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        
                        Text(tavola.status.rawValue)
                            .font(.caption)
                            .foregroundColor(statusColor)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            TavolaDetailView(tavola: tavola)
        }
    }
    
    private func iconForStatus(_ status: TavolaStatus) -> String {
        switch status {
        case .completata: return "checkmark.circle.fill"
        case .programmato: return "clock.fill"
        case .inPreparazione: return "pencil.circle.fill"
        }
    }
}

struct TavolaDetailView: View {
    @Environment(\.dismiss) var dismiss
    let tavola: Tavola
    @StateObject private var dataService = DataService.shared
    @State private var showingPDF = false
    @State private var showingTornata = false
    
    var tornata: Tornata? {
        guard let tornataId = tavola.idTornata else { return nil }
        return dataService.tornate.first { $0.id == tornataId }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(tavola.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        HStack {
                            StatusBadge(status: tavola.status)
                            
                            if let date = tavola.formattedPresentationDate {
                                Text("•")
                                    .foregroundColor(.gray)
                                
                                Text(date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // PDF Button
                    if let pdfURL = tavola.pdfURL {
                        Button(action: { showingPDF = true }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text("Visualizza PDF")
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(AppTheme.masonicBlue)
                            .cornerRadius(12)
                        }
                        .sheet(isPresented: $showingPDF) {
                            PDFViewerView(pdfURL: pdfURL, titolo: tavola.title)
                        }
                    }
                    
                    // Tornata Link
                    if let tornata = tornata {
                        Button(action: { showingTornata = true }) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "waveform")
                                        .font(.title2)
                                        .foregroundColor(AppTheme.masonicGold)
                                    
                                    Text("Vai alla Discussione Audio")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.masonicBlue)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.gray)
                                }
                                
                                Text("Tornata: \(tornata.title)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text(tornata.shortDate)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .cardStyle()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .sheet(isPresented: $showingTornata) {
                            if let brother = AuthenticationService.shared.currentBrother {
                                TornataDetailView(tornata: tornata, brother: brother)
                            }
                        }
                    }
                    
                    // Contenuto
                    if let content = tavola.content {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Contenuto")
                                .font(.headline)
                                .foregroundColor(AppTheme.masonicBlue)
                            
                            Text(content)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                    } else {
                        EmptyStateView(
                            icon: "doc.text",
                            message: "Contenuto non disponibile"
                        )
                        .padding()
                        .cardStyle()
                    }
                }
                .padding()
            }
            .background(AppTheme.background)
            #if os(iOS)
            .navigationBarItems(trailing: Button("Chiudi") {
                dismiss()
            })
            #else
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            #endif
        }
    }
}

struct StatusBadge: View {
    let status: TavolaStatus
    
    var color: Color {
        switch status {
        case .completata: return AppTheme.success
        case .programmato: return AppTheme.warning
        case .inPreparazione: return AppTheme.masonicBlue
        }
    }
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color)
            .cornerRadius(8)
    }
}

#Preview {
    TavoleView(brother: Brother(
        firstName: "Paolo Giulio",
        lastName: "Gazzano",
        email: "demo@kilwinning.it",
        degree: .maestro,
        role: .venerabileMaestro,
        isAdmin: true
    ))
}
