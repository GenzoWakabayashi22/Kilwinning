import Foundation

/// Stato di un prestito
enum PrestitoStato: String, Codable, CaseIterable {
    case richiesto = "Richiesto"
    case attivo = "Attivo"
    case concluso = "Concluso"
    case scaduto = "Scaduto"

    var icon: String {
        switch self {
        case .richiesto: return "hourglass"
        case .attivo: return "book.fill"
        case .concluso: return "checkmark.circle.fill"
        case .scaduto: return "exclamationmark.triangle.fill"
        }
    }

    var color: String {
        switch self {
        case .richiesto: return "orange"
        case .attivo: return "blue"
        case .concluso: return "green"
        case .scaduto: return "red"
        }
    }
}

/// Modello dati completo per un prestito di libro
struct Prestito: Identifiable, Codable {
    let id: Int
    var idLibro: Int
    var idFratello: Int // ID fratello (non UUID, dal database)
    var dataInizio: Date?
    var dataFine: Date?
    var dataScadenza: Date?
    var stato: PrestitoStato

    // Campi calcolati/joined per visualizzazione
    var titoloLibro: String?
    var autoreLibro: String?
    var nomeFratello: String?

    enum CodingKeys: String, CodingKey {
        case id
        case idLibro = "id_libro"
        case idFratello = "id_fratello"
        case dataInizio = "data_inizio"
        case dataFine = "data_fine"
        case dataScadenza = "data_scadenza"
        case stato
        case titoloLibro = "titolo_libro"
        case autoreLibro = "autore_libro"
        case nomeFratello = "nome_fratello"
    }

    var formattedDataInizio: String {
        guard let date = dataInizio else { return "Non ancora iniziato" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }

    var formattedDataFine: String? {
        guard let date = dataFine else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }

    var formattedDataScadenza: String? {
        guard let date = dataScadenza else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }

    var giorniRimanenti: Int? {
        guard let scadenza = dataScadenza, stato == .attivo else { return nil }
        let giorni = Calendar.current.dateComponents([.day], from: Date(), to: scadenza).day
        return giorni
    }

    var isInScadenza: Bool {
        guard let giorni = giorniRimanenti else { return false }
        return giorni <= 3 && giorni >= 0
    }

    var isScaduto: Bool {
        guard let giorni = giorniRimanenti else { return false }
        return giorni < 0
    }

    init(id: Int,
         idLibro: Int,
         idFratello: Int,
         dataInizio: Date? = nil,
         dataFine: Date? = nil,
         dataScadenza: Date? = nil,
         stato: PrestitoStato = .richiesto,
         titoloLibro: String? = nil,
         autoreLibro: String? = nil,
         nomeFratello: String? = nil) {
        self.id = id
        self.idLibro = idLibro
        self.idFratello = idFratello
        self.dataInizio = dataInizio
        self.dataFine = dataFine
        self.dataScadenza = dataScadenza
        self.stato = stato
        self.titoloLibro = titoloLibro
        self.autoreLibro = autoreLibro
        self.nomeFratello = nomeFratello
    }
}

/// DTO per richiedere un prestito
struct RichiestaPrestito: Codable {
    var libroId: Int

    enum CodingKeys: String, CodingKey {
        case libroId = "libro_id"
    }
}

/// DTO per approvare un prestito (admin)
struct ApprovaPrestito: Codable {
    var prestitoId: Int
    var giorniDurata: Int // Durata prestito in giorni (default 30)

    enum CodingKeys: String, CodingKey {
        case prestitoId = "prestito_id"
        case giorniDurata = "giorni_durata"
    }
}
