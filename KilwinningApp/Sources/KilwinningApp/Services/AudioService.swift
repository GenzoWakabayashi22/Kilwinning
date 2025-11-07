import Foundation
import Combine

/// Servizio per la gestione delle discussioni audio
@MainActor
class AudioService: ObservableObject {
    @Published var discussioni: [AudioDiscussione] = []
    
    static let shared = AudioService()
    private let networkService = NetworkService.shared
    private var useMockData = false
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutte le discussioni audio per una tornata
    func fetchDiscussioni(for tornataId: UUID) async -> [AudioDiscussione] {
        // Note: This requires mapping UUID to Int IDs from the backend
        // For now, we'll use mock data filtering
        if useMockData {
            return discussioni.filter { $0.idTornata == tornataId }
        }
        
        // TODO: Implement proper ID mapping when backend tornata management is in place
        return discussioni.filter { $0.idTornata == tornataId }
    }
    
    /// Ottieni tutte le discussioni audio
    func fetchAllDiscussioni() async {
        // For now, keep using mock data since we don't have a mapping
        // between UUID tornata IDs and backend Int IDs
        // TODO: Implement when backend tornata integration is complete
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
        // Dati di esempio - saranno popolati quando si collegano le tornate
        // Aggiungi alcune discussioni di esempio
        let tornataId = UUID() // Questo dovrebbe corrispondere a una tornata reale in produzione
        
        discussioni = [
            AudioDiscussione(
                id: 1,
                idTornata: tornataId,
                fratelloIntervento: "Fr. Marco Rossi",
                titoloIntervento: "Riflessioni sul simbolismo della Squadra",
                durata: "12:45",
                audioURL: "https://pcloud.com/audio/discussione1.mp3",
                dataUpload: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            ),
            AudioDiscussione(
                id: 2,
                idTornata: tornataId,
                fratelloIntervento: "Fr. Giuseppe Bianchi",
                titoloIntervento: "Il Compasso e la misura dell'universo",
                durata: "18:30",
                audioURL: "https://pcloud.com/audio/discussione2.mp3",
                dataUpload: Calendar.current.date(byAdding: .day, value: -5, to: Date())!
            ),
            AudioDiscussione(
                id: 3,
                idTornata: tornataId,
                fratelloIntervento: "Fr. Andrea Verdi",
                titoloIntervento: "L'equilibrio tra materia e spirito",
                durata: "15:20",
                audioURL: "https://pcloud.com/audio/discussione3.mp3",
                dataUpload: Calendar.current.date(byAdding: .day, value: -4, to: Date())!
            )
        ]
    }
}
