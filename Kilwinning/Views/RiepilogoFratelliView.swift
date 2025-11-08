import SwiftUI

/// View showing summary of all fratelli presences
struct RiepilogoFratelliView: View {
    @StateObject private var apiService = TornateAPIService()
    @State private var riepilogo: [FratelloRiepilogo] = []
    @State private var selectedYear: String = "2025"
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let availableYears = ["2020", "2021", "2022", "2023", "2024", "2025", "Tutti"]

    var body: some View {
        VStack(spacing: 0) {
            // Year picker
            Picker("Anno", selection: $selectedYear) {
                ForEach(availableYears, id: \.self) { year in
                    Text(year).tag(year)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .onChange(of: selectedYear) { _, _ in
                Task {
                    await loadRiepilogo()
                }
            }

            if isLoading {
                ProgressView("Caricamento...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)

                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Button("Riprova") {
                        Task {
                            await loadRiepilogo()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                List {
                    ForEach(riepilogo) { fratello in
                        FratelloRiepilogoRow(fratello: fratello)
                    }
                }
                .listStyle(.plain)
                .refreshable {
                    await loadRiepilogo()
                }
            }
        }
        .navigationTitle("Riepilogo Fratelli")
        .task {
            await loadRiepilogo()
        }
    }

    private func loadRiepilogo() async {
        isLoading = true
        errorMessage = nil

        do {
            let yearParam = selectedYear.lowercased() == "tutti" ? "tutti" : selectedYear
            riepilogo = try await apiService.getRiepilogoFratelli(anno: yearParam)
        } catch {
            errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
        }

        isLoading = false
    }
}

// MARK: - FratelloRiepilogoRow

struct FratelloRiepilogoRow: View {
    let fratello: FratelloRiepilogo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with name and degree
            HStack {
                Text(fratello.nome)
                    .font(.headline)

                Spacer()

                DegreeBadge(grado: fratello.grado)
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Presenze:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(fratello.presenze)/\(fratello.tornateDisponibili)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                ProgressBar(value: fratello.percentuale)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RiepilogoFratelliView()
    }
}
