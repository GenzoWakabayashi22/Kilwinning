import Foundation
import Combine

/// Servizio per la gestione delle discussioni audio
@MainActor
class AudioService: ObservableObject {
    @Published var discussioni: [AudioDiscussione] = []
    
    static let shared = AudioService()
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutte le discussioni audio per una tornata
    func fetchDiscussioni(for tornataId: UUID) async -> [AudioDiscussione] {
        // TODO: Implementare chiamata reale a backend
        try? await Task.sleep(nanoseconds: 500_000_000)
        return discussioni.filter { $0.idTornata == tornataId }
    }
    
    /// Ottieni tutte le discussioni audio
    func fetchAllDiscussioni() async {
        // TODO: Implementare chiamata reale a backend
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    // MARK: - CRUD Operations
    
    /// Aggiungi una nuova discussione audio
    func addDiscussione(_ discussione: AudioDiscussione) async {
        // TODO: Implementare chiamata reale a backend
        discussioni.append(discussione)
        discussioni.sort { $0.dataUpload > $1.dataUpload }
    }
    
    /// Aggiorna una discussione audio esistente
    func updateDiscussione(_ discussione: AudioDiscussione) async {
        // TODO: Implementare chiamata reale a backend
        if let index = discussioni.firstIndex(where: { $0.id == discussione.id }) {
            discussioni[index] = discussione
        }
    }
    
    /// Elimina una discussione audio
    func deleteDiscussione(_ discussione: AudioDiscussione) async {
        // TODO: Implementare chiamata reale a backend
        discussioni.removeAll { $0.id == discussione.id }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Dati di esempio vuoti - saranno popolati quando si collegano le tornate
        discussioni = []
    }
}
