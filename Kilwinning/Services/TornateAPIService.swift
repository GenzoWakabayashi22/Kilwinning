import Foundation

/// API Service for Node.js backend integration
/// Connects to https://tornate.loggiakilwinning.com/api
@MainActor
class TornateAPIService: ObservableObject {

    // MARK: - Configuration

    private let baseURL = "https://tornate.loggiakilwinning.com/api"
    private let timeout: TimeInterval = 30

    private var authToken: String? {
        KeychainHelper.shared.getToken()
    }

    // MARK: - Generic Request Methods

    /// Perform authenticated GET request
    private func get<T: Decodable>(endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        var urlString = baseURL + endpoint

        // Add query parameters
        if let params = queryParams, !params.isEmpty {
            let queryString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
                .joined(separator: "&")
            urlString += "?" + queryString
        }

        guard let url = URL(string: urlString) else {
            throw TornateAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TornateAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TornateAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: data)
    }

    /// Perform authenticated POST request
    private func post<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw TornateAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.timeoutInterval = timeout

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TornateAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TornateAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(R.self, from: data)
    }

    /// Perform authenticated PUT request
    private func put<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        guard let url = URL(string: baseURL + endpoint) else {
            throw TornateAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.timeoutInterval = timeout

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TornateAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TornateAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(R.self, from: data)
    }

    /// Perform authenticated DELETE request
    private func delete(endpoint: String) async throws {
        guard let url = URL(string: baseURL + endpoint) else {
            throw TornateAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.timeoutInterval = timeout

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw TornateAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw TornateAPIError.httpError(statusCode: httpResponse.statusCode)
        }
    }

    // MARK: - Authentication

    /// Login fratello
    func login(nome: String) async throws -> LoginResponse {
        let body = LoginRequest(nome: nome)
        return try await post(endpoint: "/fratelli/login", body: body)
    }

    /// Verify current session
    func verifySession() async throws -> Brother {
        return try await get(endpoint: "/fratelli/me")
    }

    /// Logout
    func logout() async throws {
        try await post(endpoint: "/fratelli/logout", body: EmptyBody())
        KeychainHelper.shared.clearAll()
    }

    // MARK: - Fratelli

    /// Get all fratelli
    func getFratelli() async throws -> [Brother] {
        return try await get(endpoint: "/fratelli")
    }

    /// Update fratello gradi
    func updateFratello(id: Int, grado: String, dataIniziazione: Date?, dataPassaggio: Date?, dataElevazione: Date?) async throws -> Brother {
        let body = UpdateFratelloRequest(
            grado: grado,
            dataIniziazione: dataIniziazione,
            dataPassaggio: dataPassaggio,
            dataElevazione: dataElevazione
        )
        return try await put(endpoint: "/fratelli/\(id)", body: body)
    }

    // MARK: - Presenze

    /// Get presenze for a fratello (with optional year filter)
    /// IMPORTANT: Backend automatically filters tornate >= dataIniziazione
    func getPresenze(fratelloId: Int, anno: String = "tutti") async throws -> [Presence] {
        let params = anno == "tutti" ? nil : ["anno": anno]
        return try await get(endpoint: "/presenze/fratello/\(fratelloId)", queryParams: params)
    }

    /// Get statistics for a fratello
    func getStatistiche(fratelloId: Int, anno: String = "tutti") async throws -> PresenceStatistics {
        let params = anno == "tutti" ? nil : ["anno": anno]
        return try await get(endpoint: "/presenze/fratello/\(fratelloId)/statistiche", queryParams: params)
    }

    /// Get riepilogo for all fratelli
    func getRiepilogoFratelli(anno: String = "2025") async throws -> [FratelloRiepilogo] {
        return try await get(endpoint: "/presenze/riepilogo-fratelli", queryParams: ["anno": anno])
    }

    /// Update presenza status
    func updatePresenza(tornataId: Int, presente: Bool) async throws -> PresenceUpdateResponse {
        let body = UpdatePresenzaRequest(tornataId: tornataId, presente: presente)
        return try await post(endpoint: "/presenze", body: body)
    }

    // MARK: - Tornate

    /// Get tornate (with optional filters)
    func getTornate(anno: String? = nil, stato: String? = nil) async throws -> [Tornata] {
        var params: [String: String] = [:]
        if let anno = anno { params["anno"] = anno }
        if let stato = stato { params["stato"] = stato }
        return try await get(endpoint: "/tornate", queryParams: params.isEmpty ? nil : params)
    }

    /// Create tornata (admin only)
    func createTornata(tornata: CreateTornataRequest) async throws -> Tornata {
        return try await post(endpoint: "/admin/tornate", body: tornata)
    }

    /// Update tornata (admin only)
    func updateTornata(id: Int, tornata: UpdateTornataRequest) async throws -> Tornata {
        return try await put(endpoint: "/admin/tornate/\(id)", body: tornata)
    }

    /// Delete tornata (admin only)
    func deleteTornata(id: Int) async throws {
        try await delete(endpoint: "/admin/tornate/\(id)")
    }
}

// MARK: - Error Types

enum TornateAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case unauthorized
    case sessionExpired

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .invalidResponse:
            return "Risposta del server non valida"
        case .httpError(let statusCode):
            return httpErrorMessage(for: statusCode)
        case .unauthorized:
            return "Accesso negato. Effettua nuovamente il login."
        case .sessionExpired:
            return "Sessione scaduta. Effettua nuovamente il login."
        }
    }

    private func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 401:
            return "Autenticazione richiesta. Effettua nuovamente il login."
        case 403:
            return "Accesso negato. Non hai i permessi necessari."
        case 404:
            return "Risorsa non trovata"
        case 500:
            return "Errore del server. Riprova più tardi."
        default:
            return "Errore di rete (\(statusCode))"
        }
    }
}

// MARK: - Request/Response Models

struct LoginRequest: Codable {
    let nome: String
}

struct LoginResponse: Codable {
    let user: Brother
    let adminAccess: Bool

    enum CodingKeys: String, CodingKey {
        case user
        case adminAccess = "admin_access"
    }
}

struct UpdateFratelloRequest: Codable {
    let grado: String
    let dataIniziazione: Date?
    let dataPassaggio: Date?
    let dataElevazione: Date?

    enum CodingKeys: String, CodingKey {
        case grado
        case dataIniziazione = "data_iniziazione"
        case dataPassaggio = "data_passaggio"
        case dataElevazione = "data_elevazione"
    }
}

struct UpdatePresenzaRequest: Codable {
    let tornataId: Int
    let presente: Bool

    enum CodingKeys: String, CodingKey {
        case tornataId = "tornata_id"
        case presente
    }
}

struct PresenceUpdateResponse: Codable {
    let success: Bool
    let message: String?
}

struct CreateTornataRequest: Codable {
    let data: Date
    let discussione: String
    let location: String
    let cena: Bool
    let tipo: String

    enum CodingKeys: String, CodingKey {
        case data
        case discussione
        case location
        case cena
        case tipo
    }
}

struct UpdateTornataRequest: Codable {
    let data: Date?
    let discussione: String?
    let location: String?
    let cena: Bool?
    let tipo: String?
    let stato: String?

    enum CodingKeys: String, CodingKey {
        case data
        case discussione
        case location
        case cena
        case tipo
        case stato
    }
}

struct FratelloRiepilogo: Codable, Identifiable {
    let id: Int
    let nome: String
    let grado: String
    let presenze: Int
    let tornateDisponibili: Int
    let percentuale: Int

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case grado
        case presenze
        case tornateDisponibili = "tornate_disponibili"
        case percentuale
    }
}

struct EmptyBody: Codable {}
