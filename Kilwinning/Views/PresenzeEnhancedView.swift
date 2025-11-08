import SwiftUI

/// Enhanced Presenze View with year filter and API integration
struct PresenzeEnhancedView: View {
    let fratelloId: Int
    let dataIniziazione: Date?

    @StateObject private var apiService = TornateAPIService()
    @State private var selectedYear: String = "2025"
    @State private var presences: [Presence] = []
    @State private var tornate: [Tornata] = []
    @State private var statistics: PresenceStatistics?
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
                    await loadData()
                }
            }

            if isLoading {
                ProgressView("Caricamento...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                ErrorView(message: error) {
                    Task {
                        await loadData()
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Statistics header
                        if let stats = statistics {
                            StatisticsHeader(statistics: stats)
                                .padding(.horizontal)
                        }

                        // Tornate list with toggle
                        VStack(spacing: 0) {
                            Text("Tornate")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .padding(.bottom, 8)

                            ForEach(filteredTornate) { tornata in
                                TornataPresenceRow(
                                    tornata: tornata,
                                    isPresent: isPresent(tornataId: tornata.id),
                                    onToggle: { isPresent in
                                        Task {
                                            await togglePresence(tornataId: tornata.id, presente: isPresent)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await loadData()
                }
            }
        }
        .navigationTitle("Le Mie Presenze")
        .task {
            await loadData()
        }
    }

    // MARK: - Computed Properties

    /// Filter tornate by initiation date
    private var filteredTornate: [Tornata] {
        PresenceCalculator.filterTornateByInitiation(
            tornate: tornate,
            dataIniziazione: dataIniziazione
        )
        .sorted { $0.data > $1.data }
    }

    // MARK: - Helper Methods

    private func isPresent(tornataId: Int) -> Bool {
        presences.first(where: { $0.tornataId == tornataId })?.presente ?? false
    }

    private func loadData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let presenzeFetch = apiService.getPresenze(fratelloId: fratelloId, anno: selectedYear)
            async let tornateFetch = apiService.getTornate(anno: selectedYear == "Tutti" ? nil : selectedYear)
            async let statisticheFetch = apiService.getStatistiche(fratelloId: fratelloId, anno: selectedYear)

            presences = try await presenzeFetch
            tornate = try await tornateFetch
            statistics = try await statisticheFetch
        } catch {
            errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func togglePresence(tornataId: Int, presente: Bool) async {
        do {
            _ = try await apiService.updatePresenza(tornataId: tornataId, presente: presente)

            // Update local state
            if let index = presences.firstIndex(where: { $0.tornataId == tornataId }) {
                presences[index] = Presence(
                    id: presences[index].id,
                    brotherId: fratelloId,
                    tornataId: tornataId,
                    presente: presente
                )
            } else {
                presences.append(Presence(
                    brotherId: fratelloId,
                    tornataId: tornataId,
                    presente: presente
                ))
            }

            // Reload statistics
            statistics = try await apiService.getStatistiche(fratelloId: fratelloId, anno: selectedYear)
        } catch {
            errorMessage = "Errore nell'aggiornamento: \(error.localizedDescription)"
        }
    }
}

// MARK: - StatisticsHeader

struct StatisticsHeader: View {
    let statistics: PresenceStatistics

    var body: some View {
        VStack(spacing: 16) {
            Text("Statistiche")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                StatItem(
                    icon: "list.bullet",
                    value: "\(statistics.totalTornate)",
                    label: "Tornate",
                    color: .blue
                )

                StatItem(
                    icon: "checkmark.circle.fill",
                    value: "\(statistics.presences)",
                    label: "Presenze",
                    color: .green
                )

                StatItem(
                    icon: "percent",
                    value: "\(statistics.percentuale)",
                    label: "Percentuale",
                    color: .orange
                )
            }

            // Consecutive presences
            if statistics.consecutivePresences > 0 {
                HStack {
                    Text("Presenze consecutive:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    ConsecutiveBadge(count: statistics.consecutivePresences)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - TornataPresenceRow

struct TornataPresenceRow: View {
    let tornata: Tornata
    let isPresent: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tornata.discussione)
                    .font(.headline)

                HStack {
                    Text(tornata.data, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if tornata.cena {
                        Text("🍴")
                            .font(.caption)
                    }

                    StatoBadge(stato: tornata.stato)
                }
            }

            Spacer()

            Toggle("", isOn: Binding(
                get: { isPresent },
                set: { onToggle($0) }
            ))
            .labelsHidden()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - ErrorView

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("Riprova") {
                onRetry()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PresenzeEnhancedView(
            fratelloId: 1,
            dataIniziazione: Date()
        )
    }
}
