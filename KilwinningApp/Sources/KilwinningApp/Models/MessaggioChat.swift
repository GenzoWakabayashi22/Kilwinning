import Foundation

/// Stato di un messaggio
enum MessaggioStato: String, Codable {
    case inviato = "Inviato"
    case ricevuto = "Ricevuto"
    case letto = "Letto"
}

/// Modello dati per un messaggio di chat
struct MessaggioChat: Identifiable, Codable {
    let id: Int
    var idChat: Int
    var idMittente: UUID // ID del fratello che ha inviato il messaggio
    var testo: String
    var timestamp: Date
    var stato: MessaggioStato
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: timestamp)
    }
    
    var formattedFullTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: timestamp)
    }
    
    init(id: Int,
         idChat: Int,
         idMittente: UUID,
         testo: String,
         timestamp: Date = Date(),
         stato: MessaggioStato = .inviato) {
        self.id = id
        self.idChat = idChat
        self.idMittente = idMittente
        self.testo = testo
        self.timestamp = timestamp
        self.stato = stato
    }
}
