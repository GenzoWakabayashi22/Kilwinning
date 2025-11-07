import Foundation

/// Stato di un prestito
enum PrestitoStato: String, Codable, CaseIterable {
    case attivo = "Attivo"
    case concluso = "Concluso"
}

/// Modello dati per un prestito di libro
struct Prestito: Identifiable, Codable {
    let id: Int
    var idLibro: Int
    var idFratello: UUID // Collegamento al fratello
    var dataInizio: Date
    var dataFine: Date?
    var stato: PrestitoStato
    
    var formattedDataInizio: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataInizio)
    }
    
    var formattedDataFine: String? {
        guard let date = dataFine else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    init(id: Int,
         idLibro: Int,
         idFratello: UUID,
         dataInizio: Date = Date(),
         dataFine: Date? = nil,
         stato: PrestitoStato = .attivo) {
        self.id = id
        self.idLibro = idLibro
        self.idFratello = idFratello
        self.dataInizio = dataInizio
        self.dataFine = dataFine
        self.stato = stato
    }
}
