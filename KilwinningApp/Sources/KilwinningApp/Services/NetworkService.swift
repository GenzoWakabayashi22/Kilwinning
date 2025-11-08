import Foundation

/// Network service for making HTTP requests to the backend API
@MainActor
class NetworkService: ObservableObject {

    // MARK: - Configuration

    private var apiBaseURL: String {
        // Check for Config.plist first, fallback to default
        if let url = getConfigValue(for: "API_BASE_URL") {
            return url
        }
        return AppConstants.API.baseURL
    }

    private var timeout: TimeInterval {
        AppConstants.API.timeout
    }

    @available(*, deprecated, message: "Usa dependency injection con NetworkService() invece di .shared")
    static let shared = NetworkService()

    init() {}
    
    // MARK: - Generic Request Methods
    
    /// Perform a GET request
    func get<T: Decodable>(endpoint: String, queryParams: [String: String]? = nil) async throws -> T {
        var urlString = apiBaseURL + endpoint

        // Add query parameters
        if let params = queryParams, !params.isEmpty {
            let queryString = params.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0.value)" }
                .joined(separator: "&")
            urlString += "?" + queryString
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding error for \(T.self): \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("   Details: \(decodingError.detailedDescription)")
            }
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Perform a POST request
    func post<T: Encodable, R: Decodable>(endpoint: String, body: T) async throws -> R {
        guard let url = URL(string: apiBaseURL + endpoint) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(body)
        } catch {
            print("❌ Encoding error for \(T.self): \(error.localizedDescription)")
            throw NetworkError.encodingError(error)
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(R.self, from: data)
        } catch {
            print("❌ Decoding error for \(R.self): \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("   Details: \(decodingError.detailedDescription)")
            }
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Perform a DELETE request
    func delete(endpoint: String, queryParams: [String: String]? = nil) async throws {
        var urlString = apiBaseURL + endpoint

        // Add query parameters
        if let params = queryParams, !params.isEmpty {
            let queryString = params.map { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            urlString += "?" + queryString
        }

        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
    }
    
    // MARK: - Tornate API
    
    /// Fetch all tornate
    func fetchTornate() async throws -> [TornataDTO] {
        let response: APIResponse<[TornataDTO]> = try await get(endpoint: "tornate.php")
        return response.data
    }
    
    /// Fetch tornata by ID
    func fetchTornata(id: Int) async throws -> TornataDTO {
        let response: APIResponse<TornataDTO> = try await get(
            endpoint: "tornate.php",
            queryParams: ["id": String(id)]
        )
        return response.data
    }
    
    // MARK: - Presenze API
    
    /// Fetch presenze for a brother
    func fetchPresenze(fratelloId: Int) async throws -> [PresenzaDTO] {
        let response: APIResponse<[PresenzaDTO]> = try await get(
            endpoint: "presenze.php",
            queryParams: ["id_fratello": String(fratelloId)]
        )
        return response.data
    }
    
    /// Update presenza status
    func updatePresenza(fratelloId: Int, tornataId: Int, stato: String) async throws -> APISuccessResponse {
        let body = UpdatePresenzaRequest(id_fratello: fratelloId, id_tornata: tornataId, stato: stato)
        return try await post(endpoint: "presenze.php", body: body)
    }
    
    // MARK: - Library API
    
    /// Fetch all books
    func fetchLibri(filters: [String: String]? = nil) async throws -> [LibroDTO] {
        let response: APIResponse<[LibroDTO]> = try await get(
            endpoint: "libri.php",
            queryParams: filters
        )
        return response.data
    }
    
    /// Fetch loans for a brother
    func fetchPrestiti(fratelloId: Int) async throws -> [PrestitoDTO] {
        let response: APIResponse<[PrestitoDTO]> = try await get(
            endpoint: "prestiti.php",
            queryParams: ["id_fratello": String(fratelloId)]
        )
        return response.data
    }
    
    /// Create a loan
    func createPrestito(libroId: Int, fratelloId: Int) async throws -> APISuccessResponse {
        let body = CreatePrestitoRequest(id_libro: libroId, id_fratello: fratelloId)
        return try await post(endpoint: "prestiti.php", body: body)
    }
    
    /// Close a loan
    func closePrestito(prestitoId: Int) async throws -> APISuccessResponse {
        let body = ClosePrestitoRequest(id: prestitoId, close_loan: true)
        return try await post(endpoint: "prestiti.php", body: body)
    }
    
    // MARK: - Audio API
    
    /// Fetch audio discussions for a tornata
    func fetchAudioDiscussioni(tornataId: Int) async throws -> [AudioDiscussioneDTO] {
        let response: APIResponse<[AudioDiscussioneDTO]> = try await get(
            endpoint: "audio_discussioni.php",
            queryParams: ["id_tornata": String(tornataId)]
        )
        return response.data
    }
    
    // MARK: - Chat API
    
    /// Fetch all chat rooms
    func fetchChatRooms() async throws -> [ChatRoomDTO] {
        let response: APIResponse<[ChatRoomDTO]> = try await get(
            endpoint: "chat.php",
            queryParams: ["rooms": "1"]
        )
        return response.data
    }
    
    /// Fetch messages for a chat room
    func fetchChatMessages(chatId: Int) async throws -> [ChatMessageDTO] {
        let response: APIResponse<[ChatMessageDTO]> = try await get(
            endpoint: "chat.php",
            queryParams: ["id_chat": String(chatId)]
        )
        return response.data
    }
    
    /// Send a message
    func sendMessage(chatId: Int, mittenteId: Int, testo: String) async throws -> APISuccessResponse {
        let body = SendMessageRequest(id_chat: chatId, id_mittente: mittenteId, testo: testo)
        return try await post(endpoint: "chat.php", body: body)
    }
    
    // MARK: - Helper Methods
    
    private func getConfigValue(for key: String) -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            print("Warning: Config.plist not found. Using default API URL.")
            return nil
        }
        guard let config = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Warning: Could not parse Config.plist. Using default API URL.")
            return nil
        }
        let value = config[key] as? String
        if value == nil {
            print("Warning: Key '\(key)' not found in Config.plist. Using default API URL.")
        }
        return value
    }
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case noData
    case offline
    case timeout

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL non valido"
        case .invalidResponse:
            return "Risposta del server non valida"
        case .httpError(let statusCode):
            return httpErrorMessage(for: statusCode)
        case .decodingError(let error):
            return "Errore di decodifica: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Errore di codifica: \(error.localizedDescription)"
        case .noData:
            return "Nessun dato ricevuto"
        case .offline:
            return "Connessione internet assente. Verifica la tua connessione e riprova."
        case .timeout:
            return "Tempo di attesa scaduto. Il server non risponde."
        }
    }

    /// Messaggi user-friendly per codici HTTP specifici
    private func httpErrorMessage(for statusCode: Int) -> String {
        switch statusCode {
        case 400:
            return "Richiesta non valida (400)"
        case 401:
            return "Autenticazione richiesta. Effettua nuovamente il login."
        case 403:
            return "Accesso negato. Non hai i permessi necessari."
        case 404:
            return "Risorsa non trovata (404)"
        case 500:
            return "Errore del server (500). Riprova più tardi."
        case 502:
            return "Server non raggiungibile (502). Riprova più tardi."
        case 503:
            return "Servizio non disponibile (503). Riprova più tardi."
        default:
            return "Errore di rete (\(statusCode))"
        }
    }
}

// MARK: - DecodingError Extension

extension DecodingError {
    /// Descrizione dettagliata dell'errore di decodifica
    var detailedDescription: String {
        switch self {
        case .keyNotFound(let key, let context):
            return "Chiave '\(key.stringValue)' non trovata in \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            return "Tipo '\(type)' non corrisponde in \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            return "Valore di tipo '\(type)' non trovato in \(context.debugDescription)"
        case .dataCorrupted(let context):
            return "Dati corrotti: \(context.debugDescription)"
        @unknown default:
            return "Errore di decodifica sconosciuto"
        }
    }
}

// MARK: - API Response Models

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}

struct APISuccessResponse: Decodable {
    let success: Bool
    let message: String?
    let id: Int?
}

// MARK: - DTOs (Data Transfer Objects)

struct TornataDTO: Codable {
    let id: Int
    let titolo: String
    let data_tornata: String
    let tipo: String
    let luogo: String
    let presentato_da: String?
    let ha_agape: Int
    let note: String?
}

struct PresenzaDTO: Codable {
    let id: Int
    let id_fratello: Int
    let id_tornata: Int
    let stato: String
    let confermato_il: String?
}

struct LibroDTO: Codable {
    let id: Int
    let titolo: String
    let autore: String
    let anno: String
    let categoria: String
    let codice_archivio: String
    let stato: String
    let copertina_url: String?
}

struct PrestitoDTO: Codable {
    let id: Int
    let id_libro: Int
    let id_fratello: Int
    let data_prestito: String
    let data_restituzione: String?
    let data_scadenza: String
    let stato_prestito: String
}

struct AudioDiscussioneDTO: Codable {
    let id: Int
    let id_tornata: Int
    let fratello_intervento: String
    let titolo_intervento: String
    let durata: String
    let audio_url: String
    let data_upload: String
}

struct ChatRoomDTO: Codable {
    let id: Int
    let nome_chat: String
    let descrizione: String?
    let data_creazione: String
    let total_messages: Int?
    let ultimo_messaggio: String?
}

struct ChatMessageDTO: Codable {
    let id: Int
    let id_chat: Int
    let id_mittente: Int
    let testo: String
    let data_invio: String
    let letto: Int
    let mittente_nome: String?
    let mittente_cognome: String?
}

// MARK: - Request Models

struct UpdatePresenzaRequest: Codable {
    let id_fratello: Int
    let id_tornata: Int
    let stato: String
}

struct CreatePrestitoRequest: Codable {
    let id_libro: Int
    let id_fratello: Int
}

struct ClosePrestitoRequest: Codable {
    let id: Int
    let close_loan: Bool
}

struct SendMessageRequest: Codable {
    let id_chat: Int
    let id_mittente: Int
    let testo: String
}
