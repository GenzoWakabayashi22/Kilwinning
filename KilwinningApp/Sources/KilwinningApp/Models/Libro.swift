import Foundation

/// Stato di un libro nella biblioteca
enum LibroStato: String, Codable, CaseIterable {
    case disponibile = "Disponibile"
    case inPrestito = "In prestito"
}

/// Modello dati per un libro della biblioteca
struct Libro: Identifiable, Codable {
    let id: Int
    var titolo: String
    var autore: String
    var anno: String
    var categoria: String
    var codiceArchivio: String
    var stato: LibroStato
    var copertinaURL: String?
    
    init(id: Int,
         titolo: String,
         autore: String,
         anno: String,
         categoria: String,
         codiceArchivio: String,
         stato: LibroStato = .disponibile,
         copertinaURL: String? = nil) {
        self.id = id
        self.titolo = titolo
        self.autore = autore
        self.anno = anno
        self.categoria = categoria
        self.codiceArchivio = codiceArchivio
        self.stato = stato
        self.copertinaURL = copertinaURL
    }
}
