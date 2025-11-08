import Foundation

/// Privacy di una lista di lettura
enum ListaPrivacy: String, Codable, CaseIterable {
    case privata = "privata"
    case pubblica = "pubblica"

    var displayName: String {
        switch self {
        case .privata: return "Privata"
        case .pubblica: return "Pubblica"
        }
    }

    var icon: String {
        switch self {
        case .privata: return "lock.fill"
        case .pubblica: return "globe"
        }
    }
}

/// Lista di lettura personalizzata
struct ListaLettura: Identifiable, Codable {
    let id: Int
    var nome: String
    var descrizione: String?
    var icona: String // emoji
    var colore: String // hex color
    var privacy: ListaPrivacy
    var fratelloId: Int
    var nomeFratello: String? // Per liste pubbliche
    var dataCreazione: Date
    var numeroLibri: Int? // Conteggio libri nella lista

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case descrizione
        case icona
        case colore
        case privacy
        case fratelloId = "fratello_id"
        case nomeFratello = "nome_fratello"
        case dataCreazione = "data_creazione"
        case numeroLibri = "numero_libri"
    }

    init(id: Int,
         nome: String,
         descrizione: String? = nil,
         icona: String = "📖",
         colore: String = "#4A90E2",
         privacy: ListaPrivacy = .privata,
         fratelloId: Int,
         nomeFratello: String? = nil,
         dataCreazione: Date = Date(),
         numeroLibri: Int? = nil) {
        self.id = id
        self.nome = nome
        self.descrizione = descrizione
        self.icona = icona
        self.colore = colore
        self.privacy = privacy
        self.fratelloId = fratelloId
        self.nomeFratello = nomeFratello
        self.dataCreazione = dataCreazione
        self.numeroLibri = numeroLibri
    }
}

/// DTO per la creazione/modifica di una lista
struct ListaLetturaDTO: Codable {
    var nome: String
    var descrizione: String?
    var icona: String
    var colore: String
    var privacy: String
}

/// Relazione tra libro e lista
struct LibroLista: Identifiable, Codable {
    let id: Int
    var listaId: Int
    var libroId: Int
    var dataAggiunta: Date
    var ordinamento: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case listaId = "lista_id"
        case libroId = "libro_id"
        case dataAggiunta = "data_aggiunta"
        case ordinamento
    }
}
