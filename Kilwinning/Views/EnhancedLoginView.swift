import SwiftUI

/// Enhanced Login View with fratelli picker
struct EnhancedLoginView: View {
    @StateObject private var authService = EnhancedAuthenticationService()
    @StateObject private var apiService = TornateAPIService()
    @State private var fratelli: [Brother] = []
    @State private var selectedFratello: Brother?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "building.columns.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)

                            Text("Loggia Kilwinning")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Sistema Gestione Tornate")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, 50)

                        // Login form
                        VStack(spacing: 20) {
                            if isLoading && fratelli.isEmpty {
                                ProgressView("Caricamento fratelli...")
                                    .tint(.white)
                                    .padding()
                            } else if !fratelli.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Seleziona il tuo nome:")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Picker("Fratello", selection: $selectedFratello) {
                                        Text("Seleziona...").tag(nil as Brother?)

                                        ForEach(fratelli, id: \.id) { fratello in
                                            HStack {
                                                Text(PresenceCalculator.getDegreeIcon(grado: fratello.grado))
                                                Text(fratello.nome)
                                            }
                                            .tag(fratello as Brother?)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .tint(.white)
                                }
                                .padding(.horizontal)

                                Button(action: handleLogin) {
                                    HStack {
                                        if isLoading {
                                            ProgressView()
                                                .tint(.blue)
                                        } else {
                                            Image(systemName: "arrow.right.circle.fill")
                                            Text("Accedi")
                                        }
                                    }
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                }
                                .disabled(selectedFratello == nil || isLoading)
                                .padding(.horizontal)
                            }

                            // Error message
                            if let error = errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 30)

                        Spacer()

                        // Footer
                        Text("© 2025 Loggia Kilwinning")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 20)
                    }
                }
            }
            .task {
                await loadFratelli()
            }
        }
    }

    // MARK: - Methods

    private func loadFratelli() async {
        isLoading = true
        errorMessage = nil

        do {
            fratelli = try await apiService.getFratelli()

            // Sort by degree (Maestri, Compagni, Apprendisti)
            fratelli.sort { f1, f2 in
                let order = ["maestro": 0, "compagno": 1, "apprendista": 2]
                let o1 = order[f1.grado.lowercased()] ?? 99
                let o2 = order[f2.grado.lowercased()] ?? 99
                if o1 == o2 {
                    return f1.nome < f2.nome
                }
                return o1 < o2
            }
        } catch {
            errorMessage = "Errore nel caricamento: \(error.localizedDescription)"
        }

        isLoading = false
    }

    private func handleLogin() {
        guard let fratello = selectedFratello else { return }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await authService.login(nome: fratello.nome)
                // Navigation handled by parent view based on authService.isAuthenticated
            } catch {
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}

// MARK: - Preview

#Preview {
    EnhancedLoginView()
}
