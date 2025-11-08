import SwiftUI

/// Vista per gestire i prestiti del fratello
struct MieiPrestitiView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var libraryService: LibraryService
    
    var prestiti: [Prestito] {
        guard let brotherId = authService.currentBrother?.id else { return [] }
        return libraryService.fetchPrestiti(for: brotherId).sorted { ($0.dataInizio) > ($1.dataInizio) }
    }
    
    var prestitiAttivi: [Prestito] {
        prestiti.filter { $0.stato == .attivo }
    }
    
    var prestitiConclusi: [Prestito] {
        prestiti.filter { $0.stato == .concluso }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "books.vertical.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.masonicGold)
                
                Text("I Miei Prestiti")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                // Badge prestiti attivi
                if !prestitiAttivi.isEmpty {
                    Text("\(prestitiAttivi.count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.success)
                        .cornerRadius(10)
                }
            }
            .padding()
            .background(Color.systemBackground)
            
            Divider()
            
            if prestiti.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    message: "Nessun prestito registrato"
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Prestiti attivi
                        if !prestitiAttivi.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Attivi")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.masonicBlue)
                                    .padding(.horizontal)
                                
                                ForEach(prestitiAttivi, id: \.id) { prestito in
                                    PrestitoCard(prestito: prestito, isAttivo: true)
                                }
                            }
                        }
                        
                        // Prestiti conclusi
                        if !prestitiConclusi.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Storico")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)
                                
                                ForEach(prestitiConclusi, id: \.id) { prestito in
                                    PrestitoCard(prestito: prestito, isAttivo: false)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
}

/// Card per visualizzare un prestito
struct PrestitoCard: View {
    let prestito: Prestito
    let isAttivo: Bool
    
    @EnvironmentObject var libraryService: LibraryService
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var libro: Libro? {
        libraryService.libri.first { $0.id == prestito.idLibro }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Copertina
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppTheme.masonicBlue.opacity(0.1))
                        .frame(width: 60, height: 80)
                    
                    Image(systemName: "book.fill")
                        .font(.title2)
                        .foregroundColor(AppTheme.masonicBlue)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    if let libro = libro {
                        Text(libro.titolo)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(libro.autore)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Label(libro.codiceArchivio, systemImage: "number")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Libro #\(prestito.idLibro)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dal")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(prestito.formattedDataInizio)
                                .font(.caption)
                                .foregroundColor(.primary)
                        }
                        
                        if let dataFine = prestito.formattedDataFine {
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Al")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                Text(dataFine)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            
            // Pulsante restituisci (solo per prestiti attivi)
            if isAttivo {
                Button(action: { restituisciLibro() }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.uturn.backward")
                            Text("Restituisci")
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppTheme.masonicGold)
                    .cornerRadius(10)
                }
                .disabled(isLoading)
            } else {
                // Badge concluso
                HStack {
                    Spacer()
                    Text("Concluso")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .cardStyle()
        .opacity(isAttivo ? 1.0 : 0.7)
        .padding(.horizontal)
        .alert("Biblioteca", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func restituisciLibro() {
        isLoading = true
        Task {
            do {
                try await libraryService.restituisciLibro(prestitoId: prestito.id)
                alertMessage = "Libro restituito con successo!"
                showingAlert = true
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
}

#Preview {
    MieiPrestitiView()
        .environmentObject(AuthenticationService())
        .environmentObject(LibraryService())
}
