import Foundation
import Combine

/// Servizio di autenticazione
@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentBrother: Brother?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Singleton
    static let shared = AuthenticationService()
    
    private init() {
        // Verifica se c'è una sessione salvata
        loadSavedSession()
    }
    
    /// Login con email e password
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        // Simulazione chiamata API
        // TODO: Implementare chiamata reale a backend o CloudKit
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Per ora, login demo
        if email.lowercased() == "demo@kilwinning.it" && password == "demo123" {
            let brother = Brother(
                firstName: "Paolo Giulio",
                lastName: "Gazzano",
                email: email,
                degree: .maestro,
                role: .venerabileMaestro,
                isAdmin: true
            )
            currentBrother = brother
            isAuthenticated = true
            saveSession(brother: brother)
        } else {
            throw AuthError.invalidCredentials
        }
        
        isLoading = false
    }
    
    /// Registrazione nuovo fratello
    func register(firstName: String, lastName: String, email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        // Simulazione chiamata API
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implementare registrazione reale
        let brother = Brother(
            firstName: firstName,
            lastName: lastName,
            email: email,
            degree: .apprendista
        )
        
        currentBrother = brother
        isAuthenticated = true
        saveSession(brother: brother)
        
        isLoading = false
    }
    
    /// Logout
    func logout() {
        currentBrother = nil
        isAuthenticated = false
        clearSession()
    }
    
    /// Recupero password
    func resetPassword(email: String) async throws {
        isLoading = true
        errorMessage = nil
        
        // Simulazione chiamata API
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implementare recupero password reale
        
        isLoading = false
    }
    
    // MARK: - Session Management
    
    private func saveSession(brother: Brother) {
        if let encoded = try? JSONEncoder().encode(brother) {
            UserDefaults.standard.set(encoded, forKey: "currentBrother")
        }
    }
    
    private func loadSavedSession() {
        if let data = UserDefaults.standard.data(forKey: "currentBrother"),
           let brother = try? JSONDecoder().decode(Brother.self, from: data) {
            currentBrother = brother
            isAuthenticated = true
        }
    }
    
    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: "currentBrother")
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Email o password non validi"
        case .networkError:
            return "Errore di connessione"
        case .invalidData:
            return "Dati non validi"
        }
    }
}
