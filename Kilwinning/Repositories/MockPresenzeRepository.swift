import Foundation

/// Implementazione Mock del repository delle presenze per testing e sviluppo
final class MockPresenzeRepository: PresenzeRepositoryProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private var presenze: [Presence] = []

    init() {
        // Inizia con un array vuoto, le presenze vengono create al volo quando richieste
    }

    func fetchPresenze() async throws -> [Presence] {
        try await Task.sleep(nanoseconds: 300_000_000)
        lock.lock()
        defer { lock.unlock() }
        return presenze
    }

    func fetchPresenze(forBrotherId brotherId: UUID) async throws -> [Presence] {
        try await Task.sleep(nanoseconds: 300_000_000)
        lock.lock()
        defer { lock.unlock() }
        return presenze.filter { $0.brotherId == brotherId }
    }

    func updatePresence(brotherId: UUID, tornataId: UUID, status: PresenceStatus) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        
        lock.lock()
        defer { lock.unlock() }

        if let index = presenze.firstIndex(where: { $0.brotherId == brotherId && $0.tornataId == tornataId }) {
            var presence = presenze[index]
            presence.status = status
            presence.confirmedAt = Date()
            presenze[index] = presence
        } else {
            let presence = Presence(
                brotherId: brotherId,
                tornataId: tornataId,
                status: status,
                confirmedAt: Date()
            )
            presenze.append(presence)
        }
    }

    func getPresenceStatus(brotherId: UUID, tornataId: UUID) -> PresenceStatus {
        lock.lock()
        defer { lock.unlock() }
        return presenze.first { $0.brotherId == brotherId && $0.tornataId == tornataId }?.status ?? .nonConfermato
    }
}
