import SwiftUI

/// Vista principale della biblioteca
struct BibliotecaView: View {
    @StateObject private var libraryService = LibraryService.shared
    @EnvironmentObject var authService: AuthenticationService
    
    @State private var searchText = ""
    @State private var selectedStato: LibroStato? = nil
    @State private var showingAddLibro = false
    @State private var selectedLibro: Libro? = nil
    
    var filteredLibri: [Libro] {
        var libri = libraryService.libri
        
        // Applica filtro ricerca
        if !searchText.isEmpty {
            libri = libraryService.searchLibri(query: searchText)
        }
        
        // Applica filtro stato
        if let stato = selectedStato {
            libri = libri.filter { $0.stato == stato }
        }
        
        return libri.sorted { $0.titolo < $1.titolo }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "books.vertical.fill")
                        .font(.title)
                        .foregroundColor(AppTheme.masonicGold)
                    
                    Text("Biblioteca Kilwinning")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.masonicBlue)
                    
                    Spacer()
                    
                    // Badge con totale libri
                    Text("\(libraryService.libri.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.masonicBlue)
                        .cornerRadius(12)
                }
                
                // Barra di ricerca
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Cerca per titolo, autore o categoria...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Filtri
                HStack(spacing: 12) {
                    FilterChip(
                        title: "Tutti",
                        isSelected: selectedStato == nil,
                        action: { selectedStato = nil }
                    )
                    
                    FilterChip(
                        title: "Disponibili",
                        isSelected: selectedStato == .disponibile,
                        action: { selectedStato = .disponibile }
                    )
                    
                    FilterChip(
                        title: "In Prestito",
                        isSelected: selectedStato == .inPrestito,
                        action: { selectedStato = .inPrestito }
                    )
                    
                    Spacer()
                    
                    // Pulsante aggiungi (solo per bibliotecario)
                    if authService.currentBrother?.isAdmin == true {
                        Button(action: { showingAddLibro = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(AppTheme.masonicBlue)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            Divider()
            
            // Lista libri
            if filteredLibri.isEmpty {
                EmptyStateView(
                    icon: "books.vertical",
                    message: searchText.isEmpty ? "Nessun libro in catalogo" : "Nessun libro trovato"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredLibri, id: \.id) { libro in
                            LibroCard(libro: libro)
                                .onTapGesture {
                                    selectedLibro = libro
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedLibro) { libro in
            LibroDetailView(libro: libro)
        }
        .sheet(isPresented: $showingAddLibro) {
            AddLibroView()
        }
    }
}

/// Card per visualizzare un libro
struct LibroCard: View {
    let libro: Libro
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Copertina placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppTheme.masonicBlue.opacity(0.1))
                    .frame(width: 80, height: 100)
                
                if let coverURL = libro.copertinaURL {
                    // TODO: Caricare immagine da URL
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppTheme.masonicBlue)
                } else {
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                        .foregroundColor(AppTheme.masonicBlue)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(libro.titolo)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(libro.autore)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Label(libro.anno, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(libro.categoria, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text(libro.codiceArchivio)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Badge stato
                    Text(libro.stato.rawValue)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(libro.stato == .disponibile ? AppTheme.success : AppTheme.warning)
                        .cornerRadius(8)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .cardStyle()
    }
}

/// Vista dettaglio libro
struct LibroDetailView: View {
    let libro: Libro
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var libraryService = LibraryService.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    
    var hasPrestito: Bool {
        guard let brotherId = authService.currentBrother?.id else { return false }
        let prestiti = libraryService.fetchPrestitiAttivi(for: brotherId)
        return prestiti.contains { $0.idLibro == libro.id }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Copertina
                    HStack {
                        Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.masonicBlue.opacity(0.1))
                                .frame(width: 200, height: 280)
                            
                            Image(systemName: "book.fill")
                                .font(.system(size: 80))
                                .foregroundColor(AppTheme.masonicBlue)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    
                    // Informazioni
                    VStack(alignment: .leading, spacing: 16) {
                        Text(libro.titolo)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.masonicBlue)
                        
                        InfoRow(label: "Autore", value: libro.autore)
                        InfoRow(label: "Anno", value: libro.anno)
                        InfoRow(label: "Categoria", value: libro.categoria)
                        InfoRow(label: "Codice Archivio", value: libro.codiceArchivio)
                        
                        HStack {
                            Text("Stato:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(libro.stato.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(libro.stato == .disponibile ? AppTheme.success : AppTheme.warning)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .cardStyle()
                    
                    // Pulsante azione
                    if let brotherId = authService.currentBrother?.id {
                        if hasPrestito {
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
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.masonicGold)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .fontWeight(.semibold)
                            }
                            .disabled(isLoading)
                        } else if libro.stato == .disponibile {
                            Button(action: { richediPrestito() }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "book")
                                        Text("Richiedi Prestito")
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.masonicBlue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .fontWeight(.semibold)
                            }
                            .disabled(isLoading)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dettagli Libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            .alert("Biblioteca", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func richediPrestito() {
        guard let brotherId = authService.currentBrother?.id else { return }
        
        isLoading = true
        Task {
            do {
                try await libraryService.richediPrestito(libroId: libro.id, fratelloId: brotherId)
                alertMessage = "Prestito richiesto con successo!"
                showingAlert = true
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
    
    private func restituisciLibro() {
        guard let brotherId = authService.currentBrother?.id else { return }
        guard let prestito = libraryService.fetchPrestitiAttivi(for: brotherId).first(where: { $0.idLibro == libro.id }) else { return }
        
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

/// Vista per aggiungere un nuovo libro
struct AddLibroView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var libraryService = LibraryService.shared
    
    @State private var titolo = ""
    @State private var autore = ""
    @State private var anno = ""
    @State private var categoria = ""
    @State private var codiceArchivio = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informazioni Libro") {
                    TextField("Titolo", text: $titolo)
                    TextField("Autore", text: $autore)
                    TextField("Anno", text: $anno)
                    TextField("Categoria", text: $categoria)
                    TextField("Codice Archivio", text: $codiceArchivio)
                }
            }
            .navigationTitle("Nuovo Libro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Aggiungi") {
                        addLibro()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    private var isValid: Bool {
        !titolo.isEmpty && !autore.isEmpty && !anno.isEmpty && !categoria.isEmpty && !codiceArchivio.isEmpty
    }
    
    private func addLibro() {
        let newId = (libraryService.libri.map { $0.id }.max() ?? 0) + 1
        let libro = Libro(
            id: newId,
            titolo: titolo,
            autore: autore,
            anno: anno,
            categoria: categoria,
            codiceArchivio: codiceArchivio,
            stato: .disponibile
        )
        
        Task {
            await libraryService.addLibro(libro)
            dismiss()
        }
    }
}

/// Componente per filtro chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppTheme.masonicBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppTheme.masonicBlue : Color(.systemGray6))
                .cornerRadius(16)
        }
    }
}

// InfoRow and EmptyStateView moved to Utilities/CommonViews.swift to avoid duplication


#Preview {
    BibliotecaView()
        .environmentObject(AuthenticationService.shared)
}
