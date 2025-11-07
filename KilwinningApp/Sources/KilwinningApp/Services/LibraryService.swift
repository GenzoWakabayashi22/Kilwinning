import Foundation
import Combine

/// Servizio per la gestione della biblioteca
@MainActor
class LibraryService: ObservableObject {
    @Published var libri: [Libro] = []
    @Published var prestiti: [Prestito] = []
    
    static let shared = LibraryService()
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutti i libri
    func fetchLibri() async {
        // TODO: Implementare chiamata reale a backend
        try? await Task.sleep(nanoseconds: 500_000_000)
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
        // TODO: Implementare chiamata reale a backend
        guard let index = libri.firstIndex(where: { $0.id == libroId }) else {
            throw LibraryError.libroNonTrovato
        }
        
        guard libri[index].stato == .disponibile else {
            throw LibraryError.libroNonDisponibile
        }
        
        // Crea il prestito
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
        
        // Aggiorna stato del libro
        libri[index].stato = .inPrestito
    }
    
    /// Restituisci un libro
    func restituisciLibro(prestitoId: Int) async throws {
        // TODO: Implementare chiamata reale a backend
        guard let prestitoIndex = prestiti.firstIndex(where: { $0.id == prestitoId }) else {
            throw LibraryError.prestitoNonTrovato
        }
        
        let libroId = prestiti[prestitoIndex].idLibro
        guard let libroIndex = libri.firstIndex(where: { $0.id == libroId }) else {
            throw LibraryError.libroNonTrovato
        }
        
        // Aggiorna il prestito
        prestiti[prestitoIndex].dataFine = Date()
        prestiti[prestitoIndex].stato = .concluso
        
        // Aggiorna stato del libro
        libri[libroIndex].stato = .disponibile
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
