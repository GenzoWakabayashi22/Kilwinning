import SwiftUI

/// Enhanced Dashboard View with consecutive presences and statistics
struct EnhancedDashboardView: View {
    @StateObject private var authService = EnhancedAuthenticationService()
    @StateObject private var apiService = TornateAPIService()

    @State private var statistics: PresenceStatistics?
    @State private var prossimeTornate: [Tornata] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with brother info
                    if let brother = authService.currentBrother {
                        BrotherHeader(brother: brother, isAdmin: authService.isAdmin)
                    }

                    // Statistics card
                    if let stats = statistics {
                        StatisticsCard(statistics: stats)
                            .padding(.horizontal)
                    }

                    // Prossime tornate
                    ProssimeTornateSection(
                        tornate: prossimeTornate,
                        onConfirmPresence: { tornataId in
                            Task {
                                await confirmPresence(tornataId: tornataId)
                            }
                        }
                    )
                    .padding(.horizontal)

                    // Quick actions
                    QuickActionsSection(isAdmin: authService.isAdmin)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await authService.logout()
                        }
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .refreshable {
                await loadData()
            }
            .task {
                await loadData()
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
        }
    }

    // MARK: - Methods

    private func loadData() async {
        guard let brother = authService.currentBrother else { return }

        isLoading = true
        errorMessage = nil

        do {
            async let statsFetch = apiService.getStatistiche(fratelloId: brother.id, anno: "tutti")
            async let tornateFetch = apiService.getTornate(stato: "programmata")

            statistics = try await statsFetch
            prossimeTornate = try await tornateFetch

            // Sort by date (nearest first)
            prossimeTornate.sort { $0.data < $1.data }
        } catch {
            errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func confirmPresence(tornataId: Int) async {
        do {
            _ = try await apiService.updatePresenza(tornataId: tornataId, presente: true)
            // Reload statistics
            if let brother = authService.currentBrother {
                statistics = try await apiService.getStatistiche(fratelloId: brother.id, anno: "tutti")
            }
        } catch {
            errorMessage = "Errore nella conferma: \(error.localizedDescription)"
        }
    }
}

// MARK: - BrotherHeader

struct BrotherHeader: View {
    let brother: Brother
    let isAdmin: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(brother.nome)
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack {
                        DegreeBadge(grado: brother.grado)

                        if isAdmin {
                            Text("ADMIN")
                                .font(.caption)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(6)
                        }
                    }
                }

                Spacer()

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .padding(.horizontal)
    }
}

// MARK: - ProssimeTornateSection

struct ProssimeTornateSection: View {
    let tornate: [Tornata]
    let onConfirmPresence: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Prossime Tornate")
                .font(.headline)

            if tornate.isEmpty {
                Text("Nessuna tornata programmata")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(tornate.prefix(3)) { tornata in
                    VStack(spacing: 8) {
                        TornataCard(tornata: tornata)

                        Button(action: {
                            onConfirmPresence(tornata.id)
                        }) {
                            Label("Conferma Presenza", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                }
            }
        }
    }
}

// MARK: - QuickActionsSection

struct QuickActionsSection: View {
    let isAdmin: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Azioni Rapide")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                NavigationLink(destination: Text("Presenze")) {
                    QuickActionButton(
                        icon: "checkmark.circle",
                        title: "Presenze",
                        color: .green
                    )
                }

                NavigationLink(destination: Text("Tornate")) {
                    QuickActionButton(
                        icon: "calendar",
                        title: "Tornate",
                        color: .blue
                    )
                }

                NavigationLink(destination: RiepilogoFratelliView()) {
                    QuickActionButton(
                        icon: "chart.bar",
                        title: "Riepilogo",
                        color: .orange
                    )
                }

                if isAdmin {
                    NavigationLink(destination: Text("Gestione")) {
                        QuickActionButton(
                            icon: "gear",
                            title: "Gestione",
                            color: .red
                        )
                    }
                }
            }
        }
    }
}

// MARK: - QuickActionButton

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    EnhancedDashboardView()
}
