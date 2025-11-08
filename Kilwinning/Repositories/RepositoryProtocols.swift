import Foundation

// MARK: - Repository Protocols

/// Protocollo per il repository delle tornate
protocol TornateRepositoryProtocol {
    /// Recupera tutte le tornate
    func fetchTornate() async throws -> [Tornata]

    /// Recupera una tornata specifica per ID
    func fetchTornata(id: UUID) async throws -> Tornata?

    /// Crea una nuova tornata
    func createTornata(_ tornata: Tornata) async throws

    /// Aggiorna una tornata esistente
    func updateTornata(_ tornata: Tornata) async throws

    /// Elimina una tornata
    func deleteTornata(_ tornata: Tornata) async throws
}

/// Protocollo per il repository delle presenze
protocol PresenzeRepositoryProtocol {
    /// Recupera tutte le presenze
    func fetchPresenze() async throws -> [Presence]

    /// Recupera le presenze per un fratello specifico
    func fetchPresenze(forBrotherId brotherId: UUID) async throws -> [Presence]

    /// Aggiorna lo stato di presenza
    func updatePresence(brotherId: UUID, tornataId: UUID, status: PresenceStatus) async throws

    /// Recupera lo stato di presenza per un fratello e una tornata
    func getPresenceStatus(brotherId: UUID, tornataId: UUID) -> PresenceStatus
}

/// Protocollo per il repository delle tavole
protocol TavoleRepositoryProtocol {
    /// Recupera tutte le tavole
    func fetchTavole() async throws -> [Tavola]

    /// Recupera le tavole per un fratello specifico
    func fetchTavole(forBrotherId brotherId: UUID) async throws -> [Tavola]

    /// Crea una nuova tavola
    func createTavola(_ tavola: Tavola) async throws

    /// Aggiorna una tavola esistente
    func updateTavola(_ tavola: Tavola) async throws

    /// Elimina una tavola
    func deleteTavola(_ tavola: Tavola) async throws
}

/// Protocollo per il repository della biblioteca
protocol BibliotecaRepositoryProtocol {
    /// Recupera tutti i libri
    func fetchLibri() async throws -> [Libro]

    /// Recupera i libri filtrati
    func fetchLibri(filters: [String: String]) async throws -> [Libro]

    /// Recupera i prestiti per un fratello
    func fetchPrestiti(forBrotherId brotherId: UUID) async throws -> [Prestito]

    /// Crea un nuovo prestito
    func createPrestito(libroId: UUID, fratelloId: UUID) async throws

    /// Chiude un prestito
    func closePrestito(prestitoId: UUID) async throws
}

/// Protocollo per il repository dei fratelli
protocol FratelliRepositoryProtocol {
    /// Recupera tutti i fratelli
    func fetchBrothers() async throws -> [Brother]

    /// Recupera un fratello specifico per ID
    func fetchBrother(id: UUID) async throws -> Brother?
}
