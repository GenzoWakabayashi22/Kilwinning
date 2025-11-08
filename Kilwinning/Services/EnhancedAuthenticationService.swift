import Foundation
import Combine

/// Enhanced authentication service with Keychain and Node.js API integration
@MainActor
class EnhancedAuthenticationService: ObservableObject {
    @Published var currentBrother: Brother?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = TornateAPIService()
    private let keychainHelper = KeychainHelper.shared

    init() {
        // Check for existing session
        checkExistingSession()
    }

    // MARK: - Authentication

    /// Login with fratello name
    func login(nome: String) async throws {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.login(nome: nome)

            // Save to Keychain (assuming backend returns a token in the future)
            // For now, we save the user ID
            _ = keychainHelper.saveUserId(response.user.id)
            _ = keychainHelper.saveSessionTimestamp()

            // Update state
            currentBrother = response.user
            isAuthenticated = true

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }

    /// Logout
    func logout() async {
        do {
            try await apiService.logout()
        } catch {
            print("Logout error: \(error.localizedDescription)")
        }

        // Clear local state
        currentBrother = nil
        isAuthenticated = false
        keychainHelper.clearAll()
    }

    /// Verify session is still valid
    func verifySession() async throws {
        // Check if session is expired (8 hours)
        if keychainHelper.isSessionExpired() {
            throw AuthenticationError.sessionExpired
        }

        do {
            let brother = try await apiService.verifySession()
            currentBrother = brother
            isAuthenticated = true

            // Update session timestamp
            _ = keychainHelper.saveSessionTimestamp()
        } catch {
            // Session invalid - clear and throw
            currentBrother = nil
            isAuthenticated = false
            keychainHelper.clearAll()
            throw error
        }
    }

    // MARK: - Session Management

    private func checkExistingSession() {
        // Check if user ID exists in Keychain
        guard let userId = keychainHelper.getUserId() else {
            return
        }

        // Check if session is not expired
        if keychainHelper.isSessionExpired() {
            keychainHelper.clearAll()
            return
        }

        // Try to verify session with backend
        Task {
            do {
                try await verifySession()
            } catch {
                print("Session verification failed: \(error.localizedDescription)")
                keychainHelper.clearAll()
            }
        }
    }

    // MARK: - Admin Check

    var isAdmin: Bool {
        guard let brother = currentBrother else { return false }
        return PresenceCalculator.isAdmin(nome: brother.nome)
    }
}

// MARK: - Errors

enum AuthenticationError: LocalizedError {
    case invalidCredentials
    case sessionExpired
    case networkError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Credenziali non valide"
        case .sessionExpired:
            return "Sessione scaduta. Effettua nuovamente il login."
        case .networkError:
            return "Errore di connessione"
        case .unauthorized:
            return "Accesso negato"
        }
    }
}
