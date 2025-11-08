import Foundation

/// Service per gestire tutte le operazioni della biblioteca
@MainActor
class BibliotecaService: ObservableObject {

    // MARK: - Published Properties

    @Published var libri: [Libro] = []
    @Published var categorie: [Categoria] = []
    @Published var mieiPrestiti: [Prestito] = []
    @Published var listeLLettura: [ListaLettura] = []
    @Published var preferiti: Set<Int> = [] // Set di libro IDs
    @Published var statistiche: BibliotecaStatistiche?

    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let networkService: NetworkService
    private var currentFratelloId: Int?

    // MARK: - Initialization

    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }

    // MARK: - Configuration

    func setCurrentFratello(id: Int) {
        self.currentFratelloId = id
    }

    // MARK: - Libri Methods

    /// Fetch tutti i libri con filtri opzionali
    func fetchLibri(categoria: String? = nil, stato: LibroStato? = nil, searchQuery: String? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            var params: [String: String] = [:]
            if let categoria = categoria {
                params["categoria"] = categoria
            }
            if let stato = stato {
                params["stato"] = stato.rawValue
            }
            if let search = searchQuery, !search.isEmpty {
                params["search"] = search
            }

            let response: APIResponse<[LibroServerDTO]> = try await networkService.get(
                endpoint: "biblioteca/libri.php",
                queryParams: params.isEmpty ? nil : params
            )

            libri = response.data.map { convertToLibro(from: $0) }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Error fetching libri: \(error)")
        }
    }

    /// Fetch dettaglio libro singolo con recensioni
    func fetchLibroDetail(id: Int) async throws -> LibroDetail {
        let response: APIResponse<LibroDetailDTO> = try await networkService.get(
            endpoint: "biblioteca/libri.php",
            queryParams: ["id": String(id)]
        )

        return convertToLibroDetail(from: response.data)
    }

    /// Cerca libri (autocomplete)
    func searchLibri(query: String) -> [Libro] {
        guard !query.isEmpty else { return libri }

        let lowercased = query.lowercased()
        return libri.filter { libro in
            libro.titolo.lowercased().contains(lowercased) ||
            libro.autore.lowercased().contains(lowercased) ||
            libro.categoria.lowercased().contains(lowercased)
        }
    }

    /// Aggiungi nuovo libro (admin only)
    func aggiungiLibro(libro: LibroDTO) async throws -> Int {
        let response: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/libri.php",
            body: libro
        )

        guard let id = response.id else {
            throw BibliotecaError.missingData
        }

        // Refresh lista
        await fetchLibri()

        return id
    }

    /// Modifica libro esistente (admin only)
    func modificaLibro(id: Int, libro: LibroDTO) async throws {
        struct UpdateLibroRequest: Codable {
            let id: Int
            let libro: LibroDTO
        }

        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/libri.php",
            body: UpdateLibroRequest(id: id, libro: libro)
        )

        // Refresh lista
        await fetchLibri()
    }

    /// Elimina libro (admin only)
    func eliminaLibro(id: Int) async throws {
        try await networkService.delete(
            endpoint: "biblioteca/libri.php",
            queryParams: ["id": String(id)]
        )

        // Rimuovi dalla lista locale
        libri.removeAll { $0.id == id }
    }

    // MARK: - Categorie Methods

    /// Fetch tutte le categorie
    func fetchCategorie() async {
        do {
            let response: APIResponse<[Categoria]> = try await networkService.get(
                endpoint: "biblioteca/categorie.php"
            )
            categorie = response.data.sorted { $0.ordinamento < $1.ordinamento }
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching categorie: \(error)")
        }
    }

    /// Aggiungi categoria (admin only)
    func aggiungiCategoria(categoria: CategoriaDTO) async throws {
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/categorie.php",
            body: categoria
        )
        await fetchCategorie()
    }

    /// Elimina categoria (admin only)
    func eliminaCategoria(id: Int) async throws {
        try await networkService.delete(
            endpoint: "biblioteca/categorie.php",
            queryParams: ["id": String(id)]
        )
        categorie.removeAll { $0.id == id }
    }

    // MARK: - Prestiti Methods

    /// Fetch i miei prestiti
    func fetchMieiPrestiti() async {
        guard let fratelloId = currentFratelloId else {
            print("⚠️ Current fratello ID not set")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response: APIResponse<[PrestitoServerDTO]> = try await networkService.get(
                endpoint: "biblioteca/prestiti.php",
                queryParams: ["id_fratello": String(fratelloId)]
            )

            mieiPrestiti = response.data.map { convertToPrestito(from: $0) }
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            print("❌ Error fetching prestiti: \(error)")
        }
    }

    /// Richiedi prestito
    func richiediPrestito(libroId: Int) async throws {
        guard currentFratelloId != nil else {
            throw BibliotecaError.notAuthenticated
        }

        let body = RichiestaPrestito(libroId: libroId)
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/prestiti.php",
            body: body
        )

        // Refresh data
        await fetchMieiPrestiti()
        await fetchLibri()
    }

    /// Approva prestito (admin only)
    func approvaPrestito(prestitoId: Int, giorniDurata: Int = 30) async throws {
        let body = ApprovaPrestito(prestitoId: prestitoId, giorniDurata: giorniDurata)
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/prestiti.php",
            body: body
        )

        await fetchMieiPrestiti()
    }

    /// Restituisci libro
    func restituisciLibro(prestitoId: Int) async throws {
        struct RestituzioneRequest: Codable {
            let prestito_id: Int
            let action: String
        }

        let body = RestituzioneRequest(prestito_id: prestitoId, action: "restituzione")
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/prestiti.php",
            body: body
        )

        // Refresh data
        await fetchMieiPrestiti()
        await fetchLibri()
    }

    /// Fetch tutti i prestiti (admin only)
    func fetchTuttiPrestiti() async throws -> [Prestito] {
        let response: APIResponse<[PrestitoServerDTO]> = try await networkService.get(
            endpoint: "biblioteca/prestiti.php",
            queryParams: ["all": "1"]
        )

        return response.data.map { convertToPrestito(from: $0) }
    }

    /// Fetch prestiti scaduti (admin only)
    func fetchPrestitiScaduti() async throws -> [Prestito] {
        let response: APIResponse<[PrestitoServerDTO]> = try await networkService.get(
            endpoint: "biblioteca/prestiti.php",
            queryParams: ["scaduti": "1"]
        )

        return response.data.map { convertToPrestito(from: $0) }
    }

    // MARK: - Recensioni Methods

    /// Fetch recensioni per un libro
    func fetchRecensioni(libroId: Int) async throws -> [Recensione] {
        let response: APIResponse<[RecensioneServerDTO]> = try await networkService.get(
            endpoint: "biblioteca/recensioni.php",
            queryParams: ["libro_id": String(libroId)]
        )

        return response.data.map { convertToRecensione(from: $0) }
    }

    /// Aggiungi recensione
    func aggiungiRecensione(recensione: RecensioneDTO) async throws {
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/recensioni.php",
            body: recensione
        )
    }

    /// Modifica recensione
    func modificaRecensione(id: Int, recensione: RecensioneDTO) async throws {
        struct UpdateRecensioneRequest: Codable {
            let id: Int
            let recensione: RecensioneDTO
        }

        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/recensioni.php",
            body: UpdateRecensioneRequest(id: id, recensione: recensione)
        )
    }

    /// Elimina recensione
    func eliminaRecensione(id: Int) async throws {
        try await networkService.delete(
            endpoint: "biblioteca/recensioni.php",
            queryParams: ["id": String(id)]
        )
    }

    // MARK: - Liste Lettura Methods

    /// Fetch le mie liste di lettura
    func fetchListeLLettura() async {
        guard let fratelloId = currentFratelloId else {
            print("⚠️ Current fratello ID not set")
            return
        }

        do {
            let response: APIResponse<[ListaLettura]> = try await networkService.get(
                endpoint: "biblioteca/liste.php",
                queryParams: ["fratello_id": String(fratelloId)]
            )

            listeLLettura = response.data
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Error fetching liste: \(error)")
        }
    }

    /// Crea nuova lista
    func creaLista(lista: ListaLetturaDTO) async throws {
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/liste.php",
            body: lista
        )

        await fetchListeLLettura()
    }

    /// Aggiungi libro a lista
    func aggiungiLibroALista(listaId: Int, libroId: Int) async throws {
        struct AddToListRequest: Codable {
            let lista_id: Int
            let libro_id: Int
            let action: String
        }

        let body = AddToListRequest(lista_id: listaId, libro_id: libroId, action: "add_book")
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/liste.php",
            body: body
        )
    }

    /// Rimuovi libro da lista
    func rimuoviLibroDaLista(listaId: Int, libroId: Int) async throws {
        struct RemoveFromListRequest: Codable {
            let lista_id: Int
            let libro_id: Int
            let action: String
        }

        let body = RemoveFromListRequest(lista_id: listaId, libro_id: libroId, action: "remove_book")
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/liste.php",
            body: body
        )
    }

    /// Elimina lista
    func eliminaLista(id: Int) async throws {
        try await networkService.delete(
            endpoint: "biblioteca/liste.php",
            queryParams: ["id": String(id)]
        )

        listeLLettura.removeAll { $0.id == id }
    }

    // MARK: - Preferiti Methods

    /// Fetch preferiti
    func fetchPreferiti() async {
        guard let fratelloId = currentFratelloId else {
            print("⚠️ Current fratello ID not set")
            return
        }

        do {
            let response: APIResponse<[PreferitoBiblioteca]> = try await networkService.get(
                endpoint: "biblioteca/preferiti.php",
                queryParams: ["fratello_id": String(fratelloId)]
            )

            preferiti = Set(response.data.map { $0.libroId })
        } catch {
            print("❌ Error fetching preferiti: \(error)")
        }
    }

    /// Toggle preferito
    func togglePreferito(libroId: Int) async throws {
        let body = TogglePreferitoDTO(libroId: libroId)
        let _: APISuccessResponse = try await networkService.post(
            endpoint: "biblioteca/preferiti.php",
            body: body
        )

        // Update local set
        if preferiti.contains(libroId) {
            preferiti.remove(libroId)
        } else {
            preferiti.insert(libroId)
        }

        // Update libro isFavorito flag
        if let index = libri.firstIndex(where: { $0.id == libroId }) {
            libri[index].isFavorito = preferiti.contains(libroId)
        }
    }

    /// Get libri preferiti
    func getLibriPreferiti() -> [Libro] {
        libri.filter { libro in
            preferiti.contains(libro.id)
        }
    }

    // MARK: - Statistiche Methods

    /// Fetch statistiche generali
    func fetchStatistiche() async {
        do {
            let response: APIResponse<BibliotecaStatistiche> = try await networkService.get(
                endpoint: "biblioteca/stats.php"
            )

            statistiche = response.data
        } catch {
            print("❌ Error fetching statistiche: \(error)")
        }
    }

    /// Fetch statistiche avanzate (admin only)
    func fetchStatisticheAvanzate() async throws -> BibliotecaStatisticheAvanzate {
        let response: APIResponse<BibliotecaStatisticheAvanzate> = try await networkService.get(
            endpoint: "biblioteca/stats.php",
            queryParams: ["advanced": "1"]
        )

        return response.data
    }

    // MARK: - Helper Methods

    private func convertToLibro(from dto: LibroServerDTO) -> Libro {
        let stato: LibroStato
        switch dto.stato.lowercased() {
        case "disponibile":
            stato = .disponibile
        case "in prestito":
            stato = .inPrestito
        case "prenotato":
            stato = .prenotato
        default:
            stato = .disponibile
        }

        return Libro(
            id: dto.id,
            titolo: dto.titolo,
            autore: dto.autore,
            isbn: dto.isbn,
            editore: dto.editore,
            anno: dto.anno,
            categoria: dto.categoria,
            codiceArchivio: dto.codice_archivio,
            stato: stato,
            posizione: dto.posizione,
            note: dto.note,
            copertinaURL: dto.copertina_url,
            votoMedio: dto.voto_medio,
            numeroRecensioni: dto.numero_recensioni,
            dataAggiunta: parseDate(dto.data_aggiunta),
            isFavorito: preferiti.contains(dto.id)
        )
    }

    private func convertToLibroDetail(from dto: LibroDetailDTO) -> LibroDetail {
        let libro = convertToLibro(from: dto.libro)
        let recensioni = dto.recensioni?.map { convertToRecensione(from: $0) } ?? []

        return LibroDetail(
            libro: libro,
            recensioni: recensioni,
            prestitoCorrente: dto.prestitoCorrente != nil ? convertToPrestito(from: dto.prestitoCorrente!) : nil,
            storicoPrestiiti: dto.storicoPrestiiti?.map { convertToPrestito(from: $0) } ?? []
        )
    }

    private func convertToPrestito(from dto: PrestitoServerDTO) -> Prestito {
        let stato: PrestitoStato
        switch dto.stato.lowercased() {
        case "richiesto":
            stato = .richiesto
        case "attivo":
            stato = .attivo
        case "concluso":
            stato = .concluso
        case "scaduto":
            stato = .scaduto
        default:
            stato = .richiesto
        }

        return Prestito(
            id: dto.id,
            idLibro: dto.id_libro,
            idFratello: dto.id_fratello,
            dataInizio: parseDate(dto.data_inizio),
            dataFine: parseDate(dto.data_fine),
            dataScadenza: parseDate(dto.data_scadenza),
            stato: stato,
            titoloLibro: dto.titolo_libro,
            autoreLibro: dto.autore_libro,
            nomeFratello: dto.nome_fratello
        )
    }

    private func convertToRecensione(from dto: RecensioneServerDTO) -> Recensione {
        Recensione(
            id: dto.id,
            libroId: dto.libro_id,
            fratelloId: dto.fratello_id,
            nomeFratello: dto.nome_fratello,
            voto: dto.voto,
            testo: dto.testo,
            dataCreazione: parseDate(dto.data_creazione) ?? Date(),
            dataModifica: parseDate(dto.data_modifica)
        )
    }

    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            return date
        }

        // Fallback to custom format
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return customFormatter.date(from: dateString)
    }
}

// MARK: - Biblioteca Error

enum BibliotecaError: LocalizedError {
    case notAuthenticated
    case missingData
    case invalidPermissions

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Devi effettuare il login per questa operazione"
        case .missingData:
            return "Dati mancanti nella risposta del server"
        case .invalidPermissions:
            return "Non hai i permessi per questa operazione"
        }
    }
}

// MARK: - Server DTOs

struct LibroServerDTO: Codable {
    let id: Int
    let titolo: String
    let autore: String
    let isbn: String?
    let editore: String?
    let anno: String
    let categoria: String
    let codice_archivio: String
    let stato: String
    let posizione: String?
    let note: String?
    let copertina_url: String?
    let voto_medio: Double?
    let numero_recensioni: Int?
    let data_aggiunta: String?
}

struct LibroDetailDTO: Codable {
    let libro: LibroServerDTO
    let recensioni: [RecensioneServerDTO]?
    let prestitoCorrente: PrestitoServerDTO?
    let storicoPrestiiti: [PrestitoServerDTO]?
}

struct LibroDetail {
    let libro: Libro
    let recensioni: [Recensione]
    let prestitoCorrente: Prestito?
    let storicoPrestiiti: [Prestito]
}

struct PrestitoServerDTO: Codable {
    let id: Int
    let id_libro: Int
    let id_fratello: Int
    let data_inizio: String?
    let data_fine: String?
    let data_scadenza: String?
    let stato: String
    let titolo_libro: String?
    let autore_libro: String?
    let nome_fratello: String?
}

struct RecensioneServerDTO: Codable {
    let id: Int
    let libro_id: Int
    let fratello_id: Int
    let nome_fratello: String?
    let voto: Int
    let testo: String?
    let data_creazione: String
    let data_modifica: String?
}
