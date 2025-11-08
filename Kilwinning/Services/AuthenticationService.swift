import Foundation
import Combine

/// Servizio di autenticazione
@MainActor
class AuthenticationService: ObservableObject {
    @Published var currentBrother: Brother?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Singleton (deprecated - use dependency injection)
    @available(*, deprecated, message: "Usa dependency injection con AuthenticationService() invece di .shared")
    static let shared = AuthenticationService()
    
    init() {
        // Verifica se c'è una sessione salvata
        loadSavedSession()
    }
    
    /// Login con username/email e password
    func login(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        // Simulazione chiamata API
        // TODO: Implementare chiamata reale a backend o CloudKit
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Credenziali semplificate
        let username = email.lowercased()
        
        // Utente di prova
        if username == "prova" && password == "prova123" {
            let brother = Brother(
                firstName: "Fratello",
                lastName: "Prova",
                email: "prova@kilwinning.it",
                degree: .maestro,
                role: .none,
                isAdmin: false
            )
            currentBrother = brother
            isAuthenticated = true
            saveSession(brother: brother)
        }
        // Utente admin
        else if username == "admin" && password == "admin123" {
            let brother = Brother(
                firstName: "Paolo Giulio",
                lastName: "Gazzano",
                email: "admin@kilwinning.it",
                degree: .maestro,
                role: .venerabileMaestro,
                isAdmin: true
            )
            currentBrother = brother
            isAuthenticated = true
            saveSession(brother: brother)
        }
        // Manteniamo compatibilità con vecchie credenziali demo
        else if username == AppConstants.Demo.email && password == AppConstants.Demo.password {
            let brother = Brother(
                firstName: "Fratello",
                lastName: "Prova",
                email: "prova@kilwinning.it",
                degree: .maestro,
                role: .none,
                isAdmin: false
            )
            currentBrother = brother
            isAuthenticated = true
            saveSession(brother: brother)
        }
        else {
            throw AuthError.invalidCredentials
        }
        
        isLoading = false
    }
    
    /// Creazione nuovo fratello - SOLO ADMIN
    func createUser(
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        degree: MasonicDegree,
        role: InstitutionalRole
    ) async throws {
        // Verifica che l'utente corrente sia admin
        guard let currentBrother = currentBrother, currentBrother.isAdmin else {
            throw AuthError.unauthorized
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simulazione chiamata API
        // TODO: Implementare chiamata reale a backend per creare utente
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // TODO: Implementare creazione utente reale nel database
        // Per ora, simuliamo il successo
        
        isLoading = false
    }
    
    /// Logout
    func logout() {
        currentBrother = nil
        isAuthenticated = false
        clearSession()
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
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Username o password non validi"
        case .networkError:
            return "Errore di connessione"
        case .invalidData:
            return "Dati non validi"
        case .unauthorized:
            return "Non hai i permessi per eseguire questa operazione"
        }
    }
}
