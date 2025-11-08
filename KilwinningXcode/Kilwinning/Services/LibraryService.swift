import Foundation
import Combine

/// Servizio per la gestione della biblioteca
@MainActor
class LibraryService: ObservableObject {
    @Published var libri: [Libro] = []
    @Published var prestiti: [Prestito] = []
    
    @available(*, deprecated, message: "Usa dependency injection con LibraryService() invece di .shared")
    static let shared = LibraryService()
    
    private let networkService: NetworkService
    private var useMockData = false
    
    nonisolated init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
        MainActor.assumeIsolated {
            loadMockData()
        }
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutti i libri
    func fetchLibri() async {
        do {
            let dtos = try await networkService.fetchLibri()
            libri = dtos.map { convertToLibro(from: $0) }
            useMockData = false
        } catch {
            print("Error fetching libri from API: \(error). Using mock data.")
            useMockData = true
            // Mock data already loaded in init
        }
    }
    
    /// Cerca libri per titolo, autore o categoria
    func searchLibri(query: String) -> [Libro] {
        guard !query.isEmpty else { return libri }
        
        let lowercaseQuery = query.lowercased()
        return libri.filter {
            $0.titolo.lowercased().contains(lowercaseQuery) ||
            $0.autore.lowercased().contains(lowercaseQuery) ||
            $0.categoria.lowercased().contains(lowercaseQuery)
        }
    }
    
    /// Filtra libri per disponibilità
    func filterLibri(byStato stato: LibroStato?) -> [Libro] {
        guard let stato = stato else { return libri }
        return libri.filter { $0.stato == stato }
    }
    
    /// Ottieni prestiti di un fratello
    func fetchPrestiti(for brotherId: UUID) -> [Prestito] {
        return prestiti.filter { $0.idFratello == brotherId }
    }
    
    /// Ottieni prestiti attivi di un fratello
    func fetchPrestitiAttivi(for brotherId: UUID) -> [Prestito] {
        return prestiti.filter { $0.idFratello == brotherId && $0.stato == .attivo }
    }
    
    // MARK: - CRUD Operations - Libri
    
    /// Aggiungi un nuovo libro
    func addLibro(_ libro: Libro) async {
        // TODO: Implementare chiamata reale a backend
        libri.append(libro)
        libri.sort { $0.titolo < $1.titolo }
    }
    
    /// Aggiorna un libro esistente
    func updateLibro(_ libro: Libro) async {
        // TODO: Implementare chiamata reale a backend
        if let index = libri.firstIndex(where: { $0.id == libro.id }) {
            libri[index] = libro
        }
    }
    
    /// Elimina un libro
    func deleteLibro(_ libro: Libro) async {
        // TODO: Implementare chiamata reale a backend
        libri.removeAll { $0.id == libro.id }
    }
    
    // MARK: - CRUD Operations - Prestiti
    
    /// Richiedi un prestito
    func richediPrestito(libroId: Int, fratelloId: UUID) async throws {
        guard let index = libri.firstIndex(where: { $0.id == libroId }) else {
            throw LibraryError.libroNonTrovato
        }
        
        guard libri[index].stato == .disponibile else {
            throw LibraryError.libroNonDisponibile
        }
        
        // Try to create on backend if using live data
        if !useMockData {
            do {
                // Note: This requires mapping UUID to Int IDs from the backend
                // For now, we'll use a placeholder ID
                let _ = try await networkService.createPrestito(libroId: libroId, fratelloId: 1)
                
                // Update local state
                libri[index].stato = .inPrestito
                
                // Fetch updated prestiti
                // TODO: Implement proper ID mapping when backend user management is in place
            } catch {
                print("Error creating prestito on backend: \(error)")
                throw error
            }
        } else {
            // Mock implementation
            let newId = (prestiti.map { $0.id }.max() ?? 0) + 1
            let prestito = Prestito(
                id: newId,
                idLibro: libroId,
                idFratello: fratelloId,
                dataInizio: Date(),
                dataFine: nil,
                stato: .attivo
            )
            
            prestiti.append(prestito)
            libri[index].stato = .inPrestito
        }
    }
    
    /// Restituisci un libro
    func restituisciLibro(prestitoId: Int) async throws {
        guard let prestitoIndex = prestiti.firstIndex(where: { $0.id == prestitoId }) else {
            throw LibraryError.prestitoNonTrovato
        }
        
        let libroId = prestiti[prestitoIndex].idLibro
        guard let libroIndex = libri.firstIndex(where: { $0.id == libroId }) else {
            throw LibraryError.libroNonTrovato
        }
        
        // Try to close on backend if using live data
        if !useMockData {
            do {
                let _ = try await networkService.closePrestito(prestitoId: prestitoId)
                
                // Update local state
                prestiti[prestitoIndex].dataFine = Date()
                prestiti[prestitoIndex].stato = .concluso
                libri[libroIndex].stato = .disponibile
            } catch {
                print("Error closing prestito on backend: \(error)")
                throw error
            }
        } else {
            // Mock implementation
            prestiti[prestitoIndex].dataFine = Date()
            prestiti[prestitoIndex].stato = .concluso
            libri[libroIndex].stato = .disponibile
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Libri di esempio
        libri = [
            Libro(
                id: 1,
                titolo: "Il Simbolismo Massonico",
                autore: "Jules Boucher",
                anno: "1948",
                categoria: "Simbologia",
                codiceArchivio: "SIM-001",
                stato: .disponibile
            ),
            Libro(
                id: 2,
                titolo: "La Massoneria e la sua Storia",
                autore: "Albert Mackey",
                anno: "1867",
                categoria: "Storia",
                codiceArchivio: "STO-001",
                stato: .disponibile
            ),
            Libro(
                id: 3,
                titolo: "I Landmarks della Massoneria",
                autore: "Albert Mackey",
                anno: "1856",
                categoria: "Dottrina",
                codiceArchivio: "DOT-001",
                stato: .inPrestito
            )
        ]
        
        // Prestito di esempio
        prestiti = [
            Prestito(
                id: 1,
                idLibro: 3,
                idFratello: UUID(), // Placeholder
                dataInizio: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                dataFine: nil,
                stato: .attivo
            )
        ]
    }
    
    // MARK: - DTO Converters
    
    private func convertToLibro(from dto: LibroDTO) -> Libro {
        let stato: LibroStato = dto.stato.lowercased().contains("prestito") ? .inPrestito : .disponibile
        
        return Libro(
            id: dto.id,
            titolo: dto.titolo,
            autore: dto.autore,
            anno: dto.anno,
            categoria: dto.categoria,
            codiceArchivio: dto.codice_archivio,
            stato: stato,
            copertinaURL: dto.copertina_url
        )
    }
}

/// Errori del servizio biblioteca
enum LibraryError: Error, LocalizedError {
    case libroNonTrovato
    case libroNonDisponibile
    case prestitoNonTrovato
    
    var errorDescription: String? {
        switch self {
        case .libroNonTrovato:
            return "Libro non trovato"
        case .libroNonDisponibile:
            return "Libro non disponibile per il prestito"
        case .prestitoNonTrovato:
            return "Prestito non trovato"
        }
    }
}
