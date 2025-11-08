import Foundation

/// Stato di un libro nella biblioteca
enum LibroStato: String, Codable, CaseIterable {
    case disponibile = "Disponibile"
    case inPrestito = "In prestito"
    case prenotato = "Prenotato"

    var icon: String {
        switch self {
        case .disponibile: return "checkmark.circle.fill"
        case .inPrestito: return "arrow.right.circle.fill"
        case .prenotato: return "clock.fill"
        }
    }

    var color: String {
        switch self {
        case .disponibile: return "green"
        case .inPrestito: return "red"
        case .prenotato: return "orange"
        }
    }
}

/// Modello dati completo per un libro della biblioteca
struct Libro: Identifiable, Codable {
    let id: Int
    var titolo: String
    var autore: String
    var isbn: String?
    var editore: String?
    var anno: String
    var categoria: String
    var codiceArchivio: String
    var stato: LibroStato
    var posizione: String? // Posizione fisica in biblioteca
    var note: String?
    var copertinaURL: String?
    var votoMedio: Double?
    var numeroRecensioni: Int?
    var dataAggiunta: Date?
    var isFavorito: Bool? // Calcolato lato client

    enum CodingKeys: String, CodingKey {
        case id
        case titolo
        case autore
        case isbn
        case editore
        case anno
        case categoria
        case codiceArchivio = "codice_archivio"
        case stato
        case posizione
        case note
        case copertinaURL = "copertina_url"
        case votoMedio = "voto_medio"
        case numeroRecensioni = "numero_recensioni"
        case dataAggiunta = "data_aggiunta"
        case isFavorito = "is_favorito"
    }

    var stelleText: String {
        guard let voto = votoMedio else { return "Nessuna recensione" }
        let stelle = String(repeating: "⭐", count: Int(round(voto)))
        return "\(stelle) (\(String(format: "%.1f", voto)))"
    }

    var badgeColor: String {
        stato.color
    }

    init(id: Int,
         titolo: String,
         autore: String,
         isbn: String? = nil,
         editore: String? = nil,
         anno: String,
         categoria: String,
         codiceArchivio: String,
         stato: LibroStato = .disponibile,
         posizione: String? = nil,
         note: String? = nil,
         copertinaURL: String? = nil,
         votoMedio: Double? = nil,
         numeroRecensioni: Int? = nil,
         dataAggiunta: Date? = nil,
         isFavorito: Bool? = nil) {
        self.id = id
        self.titolo = titolo
        self.autore = autore
        self.isbn = isbn
        self.editore = editore
        self.anno = anno
        self.categoria = categoria
        self.codiceArchivio = codiceArchivio
        self.stato = stato
        self.posizione = posizione
        self.note = note
        self.copertinaURL = copertinaURL
        self.votoMedio = votoMedio
        self.numeroRecensioni = numeroRecensioni
        self.dataAggiunta = dataAggiunta
        self.isFavorito = isFavorito
    }
}

/// DTO per la creazione/modifica di un libro (admin only)
struct LibroDTO: Codable {
    var titolo: String
    var autore: String
    var isbn: String?
    var editore: String?
    var anno: String
    var categoria: String
    var posizione: String?
    var note: String?
    var copertinaURL: String?

    enum CodingKeys: String, CodingKey {
        case titolo
        case autore
        case isbn
        case editore
        case anno
        case categoria
        case posizione
        case note
        case copertinaURL = "copertina_url"
    }
}
