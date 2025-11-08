import Foundation

/// Implementazione Mock del repository delle tornate per testing e sviluppo
final class MockTornateRepository: TornateRepositoryProtocol, @unchecked Sendable {

    private let lock = NSLock()
    private var tornate: [Tornata] = []

    init() {
        loadMockData()
    }

    func fetchTornate() async throws -> [Tornata] {
        // Simula un ritardo di rete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 secondi
        lock.lock()
        defer { lock.unlock() }
        return tornate
    }

    func fetchTornata(id: UUID) async throws -> Tornata? {
        try await Task.sleep(nanoseconds: 300_000_000)
        lock.lock()
        defer { lock.unlock() }
        return tornate.first { $0.id == id }
    }

    func createTornata(_ tornata: Tornata) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        lock.lock()
        defer { lock.unlock() }
        tornate.append(tornata)
        tornate.sort { $0.date > $1.date }
    }

    func updateTornata(_ tornata: Tornata) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        lock.lock()
        defer { lock.unlock() }
        if let index = tornate.firstIndex(where: { $0.id == tornata.id }) {
            tornate[index] = tornata
        }
    }

    func deleteTornata(_ tornata: Tornata) async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        lock.lock()
        defer { lock.unlock() }
        tornate.removeAll { $0.id == tornata.id }
    }

    // MARK: - Mock Data

    private func loadMockData() {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 11
        dateComponents.day = 25
        dateComponents.hour = 19
        dateComponents.minute = 30

        if let date1 = calendar.date(from: dateComponents) {
            tornate.append(Tornata(
                title: "Il sentiero della saggezza",
                date: date1,
                type: .ordinaria,
                location: .tofa,
                introducedBy: "Fr. Marco Rossi",
                hasDinner: true
            ))
        }

        dateComponents.month = 12
        dateComponents.day = 10
        if let date2 = calendar.date(from: dateComponents) {
            tornate.append(Tornata(
                title: "La ricerca della verità",
                date: date2,
                type: .ordinaria,
                location: .tofa,
                introducedBy: "Fr. Giuseppe Bianchi",
                hasDinner: false
            ))
        }

        dateComponents.month = 12
        dateComponents.day = 22
        if let date3 = calendar.date(from: dateComponents) {
            tornate.append(Tornata(
                title: "Cerimonia di Passaggio di Grado",
                date: date3,
                type: .cerimonia,
                location: .tofa,
                introducedBy: "Ven.mo Maestro",
                hasDinner: true
            ))
        }
    }
}
