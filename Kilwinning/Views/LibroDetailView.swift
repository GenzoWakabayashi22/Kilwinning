import SwiftUI

/// Vista dettaglio libro completa con recensioni e azioni
struct LibroDetailView: View {
    let libro: Libro
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var bibliotecaService: BibliotecaService
    @Environment(\.dismiss) private var dismiss

    @State private var recensioni: [Recensione] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showingRecensioneForm = false
    @State private var miaRecensione: Recensione?

    var isFavorito: Bool {
        bibliotecaService.preferiti.contains(libro.id)
    }

    var hasPrestito: Bool {
        bibliotecaService.mieiPrestiti.contains { $0.idLibro == libro.id && $0.stato == .attivo }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Copertina e badge
                    ZStack(alignment: .topTrailing) {
                        HStack {
                            Spacer()
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(AppTheme.masonicBlue.opacity(0.1))
                                    .frame(width: 200, height: 280)

                                if let coverURL = libro.copertinaURL {
                                    // TODO: AsyncImage
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(AppTheme.masonicBlue)
                                } else {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(AppTheme.masonicBlue)
                                }
                            }
                            Spacer()
                        }

                        // Badge preferito
                        Button(action: { togglePreferito() }) {
                            Image(systemName: isFavorito ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorito ? .red : .gray)
                                .padding(12)
                                .background(Color.appBackground.opacity(0.9))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    .padding(.top)

                    // Informazioni libro
                    VStack(alignment: .leading, spacing: 16) {
                        Text(libro.titolo)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.masonicBlue)

                        InfoRow(label: "Autore", value: libro.autore)

                        if let editore = libro.editore {
                            InfoRow(label: "Editore", value: editore)
                        }

                        InfoRow(label: "Anno", value: libro.anno)

                        if let isbn = libro.isbn {
                            InfoRow(label: "ISBN", value: isbn)
                        }

                        InfoRow(label: "Categoria", value: libro.categoria)
                        InfoRow(label: "Codice Archivio", value: libro.codiceArchivio)

                        if let posizione = libro.posizione {
                            InfoRow(label: "Posizione", value: posizione)
                        }

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
                                .background(statoColor(libro.stato))
                                .cornerRadius(8)
                        }

                        // Note
                        if let note = libro.note, !note.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Descrizione")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text(note)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .cardStyle()

                    // Valutazione media
                    if let votoMedio = libro.votoMedio {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Valutazione Media")
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()

                                HStack(spacing: 4) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(round(votoMedio)) ? "star.fill" : "star")
                                            .font(.title3)
                                            .foregroundColor(.yellow)
                                    }
                                }

                                Text(String(format: "%.1f", votoMedio))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }

                            if let numeroRecensioni = libro.numeroRecensioni {
                                Text("\(numeroRecensioni) recension\(numeroRecensioni == 1 ? "e" : "i")")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .cardStyle()
                    }

                    // Pulsanti azione
                    VStack(spacing: 12) {
                        if hasPrestito {
                            Button(action: { restituisciLibro() }) {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.uturn.backward")
                                        Text("Restituisci Libro")
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
                        } else {
                            Text("Libro attualmente non disponibile")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appSecondaryBackground)
                                .cornerRadius(12)
                        }

                        // Pulsante recensione
                        Button(action: { showingRecensioneForm = true }) {
                            HStack {
                                Image(systemName: miaRecensione != nil ? "star.fill" : "star")
                                Text(miaRecensione != nil ? "Modifica Recensione" : "Scrivi Recensione")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appSecondaryBackground)
                            .foregroundColor(AppTheme.masonicBlue)
                            .cornerRadius(12)
                            .fontWeight(.semibold)
                        }
                    }
                    .padding(.horizontal)

                    // Recensioni
                    if !recensioni.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recensioni Fratelli")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)

                            ForEach(recensioni) { recensione in
                                RecensioneCard(recensione: recensione)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Dettagli Libro")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
            .task {
                await loadRecensioni()
            }
            .alert("Biblioteca", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showingRecensioneForm) {
                RecensioneFormView(libro: libro, recensioneEsistente: miaRecensione)
            }
        }
    }

    private func statoColor(_ stato: LibroStato) -> Color {
        switch stato {
        case .disponibile: return AppTheme.success
        case .inPrestito: return AppTheme.error
        case .prenotato: return AppTheme.warning
        }
    }

    private func loadRecensioni() async {
        do {
            recensioni = try await bibliotecaService.fetchRecensioni(libroId: libro.id)

            // Trova la mia recensione
            if let fratelloId = authService.currentBrother?.id {
                miaRecensione = recensioni.first { $0.fratelloId == fratelloId }
            }
        } catch {
            print("❌ Error loading recensioni: \(error)")
        }
    }

    private func togglePreferito() {
        Task {
            do {
                try await bibliotecaService.togglePreferito(libroId: libro.id)
            } catch {
                alertMessage = "Errore: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }

    private func richediPrestito() {
        isLoading = true
        Task {
            do {
                try await bibliotecaService.richiediPrestito(libroId: libro.id)
                alertMessage = "Richiesta prestito inviata con successo!"
                showingAlert = true
                await bibliotecaService.fetchMieiPrestiti()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }

    private func restituisciLibro() {
        guard let prestito = bibliotecaService.mieiPrestiti.first(where: { $0.idLibro == libro.id && $0.stato == .attivo }) else { return }

        isLoading = true
        Task {
            do {
                try await bibliotecaService.restituisciLibro(prestitoId: prestito.id)
                alertMessage = "Libro restituito con successo!"
                showingAlert = true
                await bibliotecaService.fetchMieiPrestiti()
            } catch {
                alertMessage = error.localizedDescription
                showingAlert = true
            }
            isLoading = false
        }
    }
}

/// Card per visualizzare una recensione
struct RecensioneCard: View {
    let recensione: Recensione

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recensione.nomeFratello ?? "Fratello")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(recensione.formattedData)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < recensione.voto ? "star.fill" : "star")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }

            if let testo = recensione.testo, !testo.isEmpty {
                Text(testo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .cardStyle()
        .padding(.horizontal)
    }
}

/// Form per aggiungere/modificare recensione
struct RecensioneFormView: View {
    let libro: Libro
    let recensioneEsistente: Recensione?

    @EnvironmentObject var bibliotecaService: BibliotecaService
    @Environment(\.dismiss) private var dismiss

    @State private var voto: Int = 5
    @State private var testo: String = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Valutazione") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Voto:")
                                .font(.headline)

                            Spacer()

                            ForEach(1...5, id: \.self) { star in
                                Button(action: { voto = star }) {
                                    Image(systemName: star <= voto ? "star.fill" : "star")
                                        .font(.title)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }

                        Text("\(voto)/5 stelle")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }

                Section("Recensione (Opzionale)") {
                    TextEditor(text: $testo)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle(recensioneEsistente != nil ? "Modifica Recensione" : "Nuova Recensione")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isLoading ? "Salvataggio..." : "Salva") {
                        salvaRecensione()
                    }
                    .disabled(isLoading)
                }
            }
            .alert("Recensione", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("successo") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if let esistente = recensioneEsistente {
                    voto = esistente.voto
                    testo = esistente.testo ?? ""
                }
            }
        }
    }

    private func salvaRecensione() {
        isLoading = true

        let recensioneDTO = RecensioneDTO(
            libroId: libro.id,
            voto: voto,
            testo: testo.isEmpty ? nil : testo
        )

        Task {
            do {
                if let esistente = recensioneEsistente {
                    try await bibliotecaService.modificaRecensione(id: esistente.id, recensione: recensioneDTO)
                } else {
                    try await bibliotecaService.aggiungiRecensione(recensione: recensioneDTO)
                }

                alertMessage = "Recensione salvata con successo!"
                showingAlert = true
            } catch {
                alertMessage = "Errore: \(error.localizedDescription)"
                showingAlert = true
            }

            isLoading = false
        }
    }
}

#Preview {
    LibroDetailView(libro: Libro(
        id: 1,
        titolo: "L'Arte Reale",
        autore: "Test Autore",
        anno: "2020",
        categoria: "Massoneria",
        codiceArchivio: "BIB0001"
    ))
    .environmentObject(AuthenticationService())
    .environmentObject(BibliotecaService())
}
