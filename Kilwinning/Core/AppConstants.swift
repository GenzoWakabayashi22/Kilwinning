import Foundation

/// Costanti centralizzate dell'applicazione
enum AppConstants {

    // MARK: - API Configuration

    enum API {
        /// URL base dell'API backend
        static let baseURL = "https://loggiakilwinning.com/api/"

        /// Timeout per le richieste di rete (in secondi)
        static let timeout: TimeInterval = 30

        /// Numero massimo di tentativi in caso di errore
        static let maxRetries = 3
    }

    // MARK: - Demo Credentials

    enum Demo {
        /// Username demo per il login di prova
        static let email = "prova"

        /// Password demo per il login di prova
        static let password = "prova123"
    }

    // MARK: - Validation Rules

    enum Validation {
        /// Lunghezza minima della password
        static let minPasswordLength = 6

        /// Lunghezza minima dell'username
        static let minUsernameLength = 3

        /// Regex per validare email (opzionale)
        static let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$"
    }

    // MARK: - Cache

    enum Cache {
        /// Durata della cache per le statistiche (in secondi)
        static let statisticsCacheDuration: TimeInterval = 300 // 5 minuti

        /// Durata della cache per le tornate (in secondi)
        static let tornateCacheDuration: TimeInterval = 600 // 10 minuti
    }

    // MARK: - UI

    enum UI {
        /// Timeout per i messaggi di feedback (in secondi)
        static let feedbackDuration: TimeInterval = 3.0

        /// Numero massimo di elementi da mostrare in preview
        static let maxPreviewItems = 5
    }
}
