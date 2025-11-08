import SwiftUI

/// Admin view for CRUD operations on tornate
struct TornateManagementView: View {
    @StateObject private var apiService = TornateAPIService()
    @State private var tornate: [Tornata] = []
    @State private var selectedYear: String = "2025"
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showCreateSheet = false
    @State private var tornataToEdit: Tornata?
    @State private var tornataToDelete: Tornata?
    @State private var showDeleteAlert = false

    private let availableYears = ["2020", "2021", "2022", "2023", "2024", "2025", "Tutti"]

    var body: some View {
        VStack(spacing: 0) {
            // Year filter
            Picker("Anno", selection: $selectedYear) {
                ForEach(availableYears, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedYear) { _, _ in
                Task {
                    await loadTornate()
                }
            }

            if isLoading {
                ProgressView("Caricamento...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(tornate) { tornata in
                        TornataCard(
                            tornata: tornata,
                            showActions: true,
                            onEdit: {
                                tornataToEdit = tornata
                            },
                            onDelete: {
                                tornataToDelete = tornata
                                showDeleteAlert = true
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await loadTornate()
                }
            }
        }
        .navigationTitle("Gestione Tornate")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showCreateSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateTornataSheet(onSave: { tornata in
                Task {
                    await createTornata(tornata)
                }
            })
        }
        .sheet(item: $tornataToEdit) { tornata in
            EditTornataSheet(tornata: tornata, onSave: { updatedTornata in
                Task {
                    await updateTornata(updatedTornata)
                }
            })
        }
        .alert("Elimina Tornata", isPresented: $showDeleteAlert) {
            Button("Annulla", role: .cancel) {}
            Button("Elimina", role: .destructive) {
                if let tornata = tornataToDelete {
                    Task {
                        await deleteTornata(tornata)
                    }
                }
            }
        } message: {
            Text("Sei sicuro di voler eliminare questa tornata?")
        }
        .alert("Errore", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
        .task {
            await loadTornate()
        }
    }

    // MARK: - Methods

    private func loadTornate() async {
        isLoading = true
        errorMessage = nil

        do {
            tornate = try await apiService.getTornate(
                anno: selectedYear == "Tutti" ? nil : selectedYear
            )
            tornate.sort { $0.data > $1.data }
        } catch {
            errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func createTornata(_ request: CreateTornataRequest) async {
        do {
            _ = try await apiService.createTornata(tornata: request)
            showCreateSheet = false
            await loadTornate()
        } catch {
            errorMessage = "Errore nella creazione: \(error.localizedDescription)"
        }
    }

    private func updateTornata(_ request: UpdateTornataRequest) async {
        guard let tornata = tornataToEdit else { return }

        do {
            _ = try await apiService.updateTornata(id: tornata.id, tornata: request)
            tornataToEdit = nil
            await loadTornate()
        } catch {
            errorMessage = "Errore nell'aggiornamento: \(error.localizedDescription)"
        }
    }

    private func deleteTornata(_ tornata: Tornata) async {
        do {
            try await apiService.deleteTornata(id: tornata.id)
            tornataToDelete = nil
            await loadTornate()
        } catch {
            errorMessage = "Errore nell'eliminazione: \(error.localizedDescription)"
        }
    }
}

// MARK: - CreateTornataSheet

struct CreateTornataSheet: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (CreateTornataRequest) -> Void

    @State private var discussione = ""
    @State private var data = Date()
    @State private var location = "Nostra Loggia - Tolfa"
    @State private var cena = false
    @State private var tipo = "ordinaria"

    var body: some View {
        NavigationStack {
            Form {
                Section("Dettagli Tornata") {
                    TextField("Discussione", text: $discussione)

                    DatePicker("Data", selection: $data, displayedComponents: [.date, .hourAndMinute])

                    Picker("Tipo", selection: $tipo) {
                        Text("Ordinaria").tag("ordinaria")
                        Text("Straordinaria").tag("straordinaria")
                    }

                    TextField("Luogo", text: $location)

                    Toggle("Cena", isOn: $cena)
                }
            }
            .navigationTitle("Nuova Tornata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let request = CreateTornataRequest(
                            data: data,
                            discussione: discussione,
                            location: location,
                            cena: cena,
                            tipo: tipo
                        )
                        onSave(request)
                        dismiss()
                    }
                    .disabled(discussione.isEmpty)
                }
            }
        }
    }
}

// MARK: - EditTornataSheet

struct EditTornataSheet: View {
    @Environment(\.dismiss) var dismiss
    let tornata: Tornata
    let onSave: (UpdateTornataRequest) -> Void

    @State private var discussione: String
    @State private var data: Date
    @State private var location: String
    @State private var cena: Bool
    @State private var tipo: String
    @State private var stato: String

    init(tornata: Tornata, onSave: @escaping (UpdateTornataRequest) -> Void) {
        self.tornata = tornata
        self.onSave = onSave
        _discussione = State(initialValue: tornata.discussione)
        _data = State(initialValue: tornata.data)
        _location = State(initialValue: tornata.location)
        _cena = State(initialValue: tornata.cena)
        _tipo = State(initialValue: tornata.tipo)
        _stato = State(initialValue: tornata.stato)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dettagli Tornata") {
                    TextField("Discussione", text: $discussione)

                    DatePicker("Data", selection: $data, displayedComponents: [.date, .hourAndMinute])

                    Picker("Tipo", selection: $tipo) {
                        Text("Ordinaria").tag("ordinaria")
                        Text("Straordinaria").tag("straordinaria")
                    }

                    TextField("Luogo", text: $location)

                    Toggle("Cena", isOn: $cena)

                    Picker("Stato", selection: $stato) {
                        Text("Programmata").tag("programmata")
                        Text("Completata").tag("completata")
                        Text("Annullata").tag("annullata")
                    }
                }
            }
            .navigationTitle("Modifica Tornata")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let request = UpdateTornataRequest(
                            data: data,
                            discussione: discussione,
                            location: location,
                            cena: cena,
                            tipo: tipo,
                            stato: stato
                        )
                        onSave(request)
                        dismiss()
                    }
                    .disabled(discussione.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TornateManagementView()
    }
}
