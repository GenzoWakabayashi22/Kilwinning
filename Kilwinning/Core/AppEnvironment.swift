import Foundation

/// Modalità di esecuzione dell'app
enum AppMode {
    case mock      // Usa dati mock per sviluppo/testing
    case live      // Usa API reali
}

/// Container delle dipendenze dell'applicazione
@MainActor
class AppEnvironment: ObservableObject {

    // MARK: - Singleton

    static let shared = AppEnvironment()

    // MARK: - Configuration

    /// Modalità corrente dell'app
    @Published var mode: AppMode = .mock {
        didSet {
            updateRepositories()
        }
    }

    // MARK: - Repositories

    private(set) var tornateRepository: TornateRepositoryProtocol
    private(set) var presenzeRepository: PresenzeRepositoryProtocol

    // MARK: - Initialization

    private init() {
        // Inizializza con repository mock per default
        self.tornateRepository = MockTornateRepository()
        self.presenzeRepository = MockPresenzeRepository()
    }

    // MARK: - Repository Management

    private func updateRepositories() {
        switch mode {
        case .mock:
            tornateRepository = MockTornateRepository()
            presenzeRepository = MockPresenzeRepository()
        case .live:
            tornateRepository = RemoteTornateRepository()
            presenzeRepository = MockPresenzeRepository() // TODO: Implementare RemotePresenzeRepository
        }
    }

    /// Passa alla modalità live (API reali)
    func switchToLiveMode() {
        mode = .live
    }

    /// Passa alla modalità mock (dati di test)
    func switchToMockMode() {
        mode = .mock
    }
}
