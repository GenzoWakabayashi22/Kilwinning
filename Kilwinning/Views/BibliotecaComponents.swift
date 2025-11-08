import SwiftUI

// MARK: - MieiPrestitiView Aggiornata

struct MieiPrestitiViewUpdated: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var bibliotecaService: BibliotecaService

    var prestitiAttivi: [Prestito] {
        bibliotecaService.mieiPrestiti.filter { $0.stato == .attivo || $0.stato == .richiesto }
    }

    var prestitiConclusi: [Prestito] {
        bibliotecaService.mieiPrestiti.filter { $0.stato == .concluso }
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
            .background(Color.appBackground)

            Divider()

            if bibliotecaService.mieiPrestiti.isEmpty {
                EmptyStateView(
                    icon: "book.closed",
                    message: "Nessun prestito registrato"
                )
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        if !prestitiAttivi.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Attivi / In Attesa")
                                    .font(.headline)
                                    .foregroundColor(AppTheme.masonicBlue)
                                    .padding(.horizontal)

                                ForEach(prestitiAttivi) { prestito in
                                    PrestitoCardUpdated(prestito: prestito, isAttivo: true)
                                }
                            }
                        }

                        if !prestitiConclusi.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Storico")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal)

                                ForEach(prestitiConclusi) { prestito in
                                    PrestitoCardUpdated(prestito: prestito, isAttivo: false)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .task {
            await bibliotecaService.fetchMieiPrestiti()
        }
        .refreshable {
            await bibliotecaService.fetchMieiPrestiti()
        }
    }
}

// MARK: - PrestitoCard Aggiornata

struct PrestitoCardUpdated: View {
    let prestito: Prestito
    let isAttivo: Bool

    @EnvironmentObject var bibliotecaService: BibliotecaService
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    var libro: Libro? {
        bibliotecaService.libri.first { $0.id == prestito.idLibro }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
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
                    } else if let titolo = prestito.titoloLibro {
                        Text(titolo)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let autore = prestito.autoreLibro {
                            Text(autore)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }

                    Divider()
                        .padding(.vertical, 4)

                    // Badge stato
                    HStack {
                        Image(systemName: prestito.stato.icon)
                            .font(.caption)

                        Text(prestito.stato.rawValue)
                            .font(.caption)

                        if let giorni = prestito.giorniRimanenti, prestito.stato == .attivo {
                            Text("•")
                                .font(.caption)

                            Text("\(giorni) giorni rimanenti")
                                .font(.caption)
                                .foregroundColor(prestito.isInScadenza ? .orange : .gray)
                        }
                    }
                    .foregroundColor(prestitoStatusColor())

                    if let scadenza = prestito.formattedDataScadenza, prestito.stato == .attivo {
                        Text("Scadenza: \(scadenza)")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }

            if isAttivo && prestito.stato == .attivo {
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
            } else if prestito.stato == .richiesto {
                Text("In attesa di approvazione")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.vertical, 6)
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

    private func prestitoStatusColor() -> Color {
        switch prestito.stato {
        case .richiesto: return .orange
        case .attivo: return prestito.isScaduto ? .red : (prestito.isInScadenza ? .orange : .blue)
        case .concluso: return .green
        case .scaduto: return .red
        }
    }

    private func restituisciLibro() {
        isLoading = true
        Task {
            do {
                try await bibliotecaService.restituisciLibro(prestitoId: prestito.id)
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

// MARK: - AddLibroView (Admin)

struct AddLibroView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var bibliotecaService: BibliotecaService

    @State private var titolo = ""
    @State private var autore = ""
    @State private var isbn = ""
    @State private var editore = ""
    @State private var anno = ""
    @State private var categoria = ""
    @State private var posizione = ""
    @State private var note = ""
    @State private var copertinaURL = ""
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Informazioni Principali") {
                    TextField("Titolo *", text: $titolo)
                    TextField("Autore *", text: $autore)
                    TextField("Anno *", text: $anno)
                }

                Section("Dettagli Aggiuntivi") {
                    TextField("ISBN", text: $isbn)
                    TextField("Editore", text: $editore)
                    TextField("Categoria *", text: $categoria)
                    TextField("Posizione in biblioteca", text: $posizione)
                }

                Section("Copertina") {
                    TextField("URL Copertina", text: $copertinaURL)
                }

                Section("Note") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Nuovo Libro")
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
                    Button(isLoading ? "Salvataggio..." : "Aggiungi") {
                        addLibro()
                    }
                    .disabled(!isValid || isLoading)
                }
            }
            .alert("Biblioteca", isPresented: $showingAlert) {
                Button("OK", role: .cancel) {
                    if alertMessage.contains("successo") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private var isValid: Bool {
        !titolo.isEmpty && !autore.isEmpty && !anno.isEmpty && !categoria.isEmpty
    }

    private func addLibro() {
        isLoading = true

        let libroDTO = LibroDTO(
            titolo: titolo,
            autore: autore,
            isbn: isbn.isEmpty ? nil : isbn,
            editore: editore.isEmpty ? nil : editore,
            anno: anno,
            categoria: categoria,
            posizione: posizione.isEmpty ? nil : posizione,
            note: note.isEmpty ? nil : note,
            copertinaURL: copertinaURL.isEmpty ? nil : copertinaURL
        )

        Task {
            do {
                _ = try await bibliotecaService.aggiungiLibro(libro: libroDTO)
                alertMessage = "Libro aggiunto con successo!"
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
    MieiPrestitiViewUpdated()
        .environmentObject(AuthenticationService())
        .environmentObject(BibliotecaService())
}
