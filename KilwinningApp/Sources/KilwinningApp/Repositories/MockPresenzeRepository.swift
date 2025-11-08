import Foundation

/// Implementazione Mock del repository delle presenze per testing e sviluppo
@MainActor
class MockPresenzeRepository: PresenzeRepositoryProtocol {

    private var presenze: [Presence] = []

    init() {
        // Inizia con un array vuoto, le presenze vengono create al volo quando richieste
    }

    func fetchPresenze() async throws -> [Presence] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return presenze
    }

    func fetchPresenze(forBrotherId brotherId: UUID) async throws -> [Presence] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return presenze.filter { $0.brotherId == brotherId }
    }

    func updatePresence(brotherId: UUID, tornataId: UUID, status: PresenceStatus) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)

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
        presenze.first { $0.brotherId == brotherId && $0.tornataId == tornataId }?.status ?? .nonConfermato
    }
}
