import Foundation

/// Tipo di notifica
enum NotificationType: String, Codable {
    case nuovaTornata = "Nuova Tornata"
    case tornataModificata = "Tornata Modificata"
    case nuovaDiscussione = "Nuova Discussione Audio"
    case nuovaTavola = "Nuova Tavola"
    case nuovoLibro = "Nuovo Libro"
    case libroRestituito = "Libro Restituito"
    case nuovoMessaggio = "Nuovo Messaggio"
}

/// Modello dati per una notifica in-app
struct Notification: Identifiable, Codable {
    let id: Int
    var tipo: NotificationType
    var titolo: String
    var messaggio: String
    var dataCreazione: Date
    var letto: Bool
    var idRiferimento: String? // ID dell'oggetto correlato (tornata, libro, ecc.)
    
    var formattedDataCreazione: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataCreazione)
    }
    
    var relativeTime: String {
        let now = Date()
        let interval = now.timeIntervalSince(dataCreazione)
        
        if interval < 60 {
            return "Ora"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) min fa"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h fa"
        } else {
            let days = Int(interval / 86400)
            return "\(days)g fa"
        }
    }
    
    init(id: Int,
         tipo: NotificationType,
         titolo: String,
         messaggio: String,
         dataCreazione: Date = Date(),
         letto: Bool = false,
         idRiferimento: String? = nil) {
        self.id = id
        self.tipo = tipo
        self.titolo = titolo
        self.messaggio = messaggio
        self.dataCreazione = dataCreazione
        self.letto = letto
        self.idRiferimento = idRiferimento
    }
}
