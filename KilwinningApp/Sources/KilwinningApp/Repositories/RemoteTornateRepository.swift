import Foundation

/// Implementazione remota del repository delle tornate che usa NetworkService
@MainActor
class RemoteTornateRepository: TornateRepositoryProtocol {

    private let networkService: NetworkService

    init(networkService: NetworkService? = nil) {
        // Usa NetworkService.shared se non fornito, ma nel contesto MainActor corretto
        self.networkService = networkService ?? NetworkService.shared
    }

    func fetchTornate() async throws -> [Tornata] {
        let dtos: [TornataDTO] = try await networkService.fetchTornate()
        return dtos.compactMap { convertToTornata(from: $0) }
    }

    func fetchTornata(id: UUID) async throws -> Tornata? {
        // Note: L'API PHP usa ID interi, quindi questa conversione potrebbe essere necessaria
        // Per ora, fetch tutte le tornate e filtra localmente
        let tornate = try await fetchTornate()
        return tornate.first { $0.id == id }
    }

    func createTornata(_ tornata: Tornata) async throws {
        // TODO: Implementare quando l'API di creazione tornate sarà disponibile
        throw NetworkError.httpError(statusCode: 501) // Not Implemented
    }

    func updateTornata(_ tornata: Tornata) async throws {
        // TODO: Implementare quando l'API di aggiornamento tornate sarà disponibile
        throw NetworkError.httpError(statusCode: 501)
    }

    func deleteTornata(_ tornata: Tornata) async throws {
        // TODO: Implementare quando l'API di eliminazione tornate sarà disponibile
        throw NetworkError.httpError(statusCode: 501)
    }

    // MARK: - DTO Conversion

    private func convertToTornata(from dto: TornataDTO) -> Tornata? {
        // Parse the date string
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: dto.data_tornata) else {
            print("Failed to parse date: \(dto.data_tornata)")
            return nil
        }

        // Map tipo to TornataType
        let type: TornataType
        switch dto.tipo.lowercased() {
        case "ordinaria":
            type = .ordinaria
        case "cerimonia":
            type = .cerimonia
        default:
            type = .ordinaria
        }

        // Map luogo to TornataLocation
        let location: TornataLocation
        if dto.luogo.lowercased().contains("tolfa") || dto.luogo.lowercased().contains("tofa") {
            location = .tofa
        } else {
            location = .visita
        }

        return Tornata(
            title: dto.titolo,
            date: date,
            type: type,
            location: location,
            introducedBy: dto.presentato_da ?? "",
            hasDinner: dto.ha_agape == 1,
            notes: dto.note
        )
    }
}
