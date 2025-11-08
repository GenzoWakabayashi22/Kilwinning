import Foundation
import Combine

/// Servizio per la gestione dei dati con repository pattern
@MainActor
class DataService: ObservableObject {

    // MARK: - Published Properties

    @Published var tornate: [Tornata] = []
    @Published var presences: [Presence] = []
    @Published var tavole: [Tavola] = []
    @Published var brothers: [Brother] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let tornateRepository: TornateRepositoryProtocol
    private let presenzeRepository: PresenzeRepositoryProtocol

    // MARK: - Cache

    private var statisticsCache: [String: (stats: PresenceStatistics, timestamp: Date)] = [:]
    private let cacheDuration: TimeInterval = AppConstants.Cache.statisticsCacheDuration

    // Dizionari indicizzati per lookup ottimizzato
    private var presencesByBrother: [UUID: [Presence]] = [:]
    private var tornateByYear: [Int: [Tornata]] = [:]

    // MARK: - Singleton (Deprecato - Usa dependency injection)

    @available(*, deprecated, message: "Usa dependency injection con DataService() invece di .shared")
    static let shared = DataService()

    // MARK: - Initialization

    init(
        tornateRepository: TornateRepositoryProtocol,
        presenzeRepository: PresenzeRepositoryProtocol
    ) {
        self.tornateRepository = tornateRepository
        self.presenzeRepository = presenzeRepository
    }

    /// Inizializzatore di convenienza che usa AppEnvironment
    convenience init() {
        let env = AppEnvironment.shared
        self.init(
            tornateRepository: env.tornateRepository,
            presenzeRepository: env.presenzeRepository
        )
    }

    // MARK: - Tornate

    /// Recupera tutte le tornate dal repository
    func fetchTornate() async {
        isLoading = true
        errorMessage = nil

        do {
            tornate = try await tornateRepository.fetchTornate()
            updateTornateIndex()
            isLoading = false
        } catch {
            errorMessage = handleError(error)
            isLoading = false
        }
    }

    func createTornata(_ tornata: Tornata) async {
        do {
            try await tornateRepository.createTornata(tornata)
            tornate.append(tornata)
            tornate.sort { $0.date > $1.date }
            updateTornateIndex()
            invalidateStatisticsCache()
        } catch {
            errorMessage = handleError(error)
        }
    }

    func updateTornata(_ tornata: Tornata) async {
        do {
            try await tornateRepository.updateTornata(tornata)
            if let index = tornate.firstIndex(where: { $0.id == tornata.id }) {
                tornate[index] = tornata
            }
            updateTornateIndex()
            invalidateStatisticsCache()
        } catch {
            errorMessage = handleError(error)
        }
    }

    func deleteTornata(_ tornata: Tornata) async {
        do {
            try await tornateRepository.deleteTornata(tornata)
            tornate.removeAll { $0.id == tornata.id }
            updateTornateIndex()
            invalidateStatisticsCache()
        } catch {
            errorMessage = handleError(error)
        }
    }

    // MARK: - Presenze

    /// Recupera tutte le presenze dal repository
    func fetchPresenze() async {
        do {
            presences = try await presenzeRepository.fetchPresenze()
            updatePresencesIndex()
        } catch {
            errorMessage = handleError(error)
        }
    }

    func updatePresence(brotherId: UUID, tornataId: UUID, status: PresenceStatus) async {
        do {
            try await presenzeRepository.updatePresence(
                brotherId: brotherId,
                tornataId: tornataId,
                status: status
            )

            // Aggiorna lo stato locale
            if let index = presences.firstIndex(where: { $0.brotherId == brotherId && $0.tornataId == tornataId }) {
                var presence = presences[index]
                presence.status = status
                presence.confirmedAt = Date()
                presences[index] = presence
            } else {
                let presence = Presence(
                    brotherId: brotherId,
                    tornataId: tornataId,
                    status: status,
                    confirmedAt: Date()
                )
                presences.append(presence)
            }

            updatePresencesIndex()
            invalidateStatisticsCache(for: brotherId)
        } catch {
            errorMessage = handleError(error)
        }
    }

    func getPresenceStatus(brotherId: UUID, tornataId: UUID) -> PresenceStatus {
        presenzeRepository.getPresenceStatus(brotherId: brotherId, tornataId: tornataId)
    }

    // MARK: - Statistics (Ottimizzate con Cache)

    func calculateStatistics(for brotherId: UUID, year: Int) -> PresenceStatistics {
        // Controlla se esiste una statistica in cache valida
        let cacheKey = "\(brotherId)-\(year)"
        if let cached = statisticsCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheDuration {
            return cached.stats
        }

        // Calcola le statistiche usando gli indici ottimizzati
        let yearTornate = tornateByYear[year] ?? []
        let brotherPresences = presencesByBrother[brotherId] ?? []

        let yearPresences = brotherPresences.filter { presence in
            yearTornate.contains { $0.id == presence.tornataId }
        }

        let presentCount = yearPresences.filter { $0.status == .presente }.count
        let absentCount = yearPresences.filter { $0.status == .assente }.count

        // Calcola presenze consecutive
        let consecutive = calculateConsecutivePresences(for: brotherId)

        let stats = PresenceStatistics(
            totalTornate: yearTornate.count,
            presences: presentCount,
            absences: absentCount,
            consecutivePresences: consecutive,
            personalRecord: consecutive
        )

        // Salva in cache
        statisticsCache[cacheKey] = (stats, Date())

        return stats
    }

    private func calculateConsecutivePresences(for brotherId: UUID) -> Int {
        let sortedTornate = tornate.sorted { $0.date < $1.date }
        var consecutive = 0
        var maxConsecutive = 0

        for tornata in sortedTornate {
            let status = getPresenceStatus(brotherId: brotherId, tornataId: tornata.id)
            if status == .presente {
                consecutive += 1
                maxConsecutive = max(maxConsecutive, consecutive)
            } else if status == .assente {
                consecutive = 0
            }
        }

        return maxConsecutive
    }

    // MARK: - Tavole

    func fetchTavole(for brotherId: UUID) -> [Tavola] {
        tavole.filter { $0.brotherId == brotherId }
    }

    func createTavola(_ tavola: Tavola) async {
        tavole.append(tavola)
    }

    func updateTavola(_ tavola: Tavola) async {
        if let index = tavole.firstIndex(where: { $0.id == tavola.id }) {
            tavole[index] = tavola
        }
    }

    // MARK: - Brothers

    func fetchBrothers() async {
        // TODO: Implementare quando avremo un FratelliRepository
    }

    // MARK: - Index Management

    private func updateTornateIndex() {
        // Crea un dizionario indicizzato per anno per lookup più veloci
        let calendar = Calendar.current
        tornateByYear = Dictionary(grouping: tornate) { tornata in
            calendar.component(.year, from: tornata.date)
        }
    }

    private func updatePresencesIndex() {
        // Crea un dizionario indicizzato per fratello per lookup più veloci
        presencesByBrother = Dictionary(grouping: presences) { $0.brotherId }
    }

    // MARK: - Cache Management

    private func invalidateStatisticsCache() {
        statisticsCache.removeAll()
    }

    private func invalidateStatisticsCache(for brotherId: UUID) {
        statisticsCache = statisticsCache.filter { key, _ in
            !key.hasPrefix(brotherId.uuidString)
        }
    }

    // MARK: - Error Handling

    private func handleError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.errorDescription ?? "Errore di rete sconosciuto"
        }
        return error.localizedDescription
    }
}
