import Foundation

/// Recensione e valutazione di un libro
struct Recensione: Identifiable, Codable {
    let id: Int
    var libroId: Int
    var fratelloId: Int
    var nomeFratello: String? // Nome del fratello per visualizzazione
    var voto: Int // 1-5 stelle
    var testo: String?
    var dataCreazione: Date
    var dataModifica: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case libroId = "libro_id"
        case fratelloId = "fratello_id"
        case nomeFratello = "nome_fratello"
        case voto
        case testo
        case dataCreazione = "data_creazione"
        case dataModifica = "data_modifica"
    }

    var formattedData: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataCreazione)
    }

    var stelleText: String {
        String(repeating: "⭐", count: voto)
    }

    init(id: Int,
         libroId: Int,
         fratelloId: Int,
         nomeFratello: String? = nil,
         voto: Int,
         testo: String? = nil,
         dataCreazione: Date = Date(),
         dataModifica: Date? = nil) {
        self.id = id
        self.libroId = libroId
        self.fratelloId = fratelloId
        self.nomeFratello = nomeFratello
        self.voto = max(1, min(5, voto)) // Clamp tra 1 e 5
        self.testo = testo
        self.dataCreazione = dataCreazione
        self.dataModifica = dataModifica
    }
}

/// DTO per la creazione/modifica di una recensione
struct RecensioneDTO: Codable {
    var libroId: Int
    var voto: Int
    var testo: String?

    enum CodingKeys: String, CodingKey {
        case libroId = "libro_id"
        case voto
        case testo
    }
}
