import Foundation

/// Tipo di chat
enum ChatType: String, Codable, CaseIterable {
    case singola = "Singola"
    case gruppo = "Gruppo"
}

/// Modello dati per una chat room
struct ChatRoom: Identifiable, Codable {
    let id: Int
    var titolo: String
    var tipo: ChatType
    var ultimoMessaggio: String?
    var ultimoAggiornamento: Date?
    var nonLetti: Int // Numero messaggi non letti
    
    var formattedUltimoAggiornamento: String? {
        guard let date = ultimoAggiornamento else { return nil }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = Locale(identifier: "it_IT")
        
        // Se il messaggio è di oggi, mostra solo l'ora
        if Calendar.current.isDateInToday(date) {
            return formatter.string(from: date)
        } else {
            // Altrimenti mostra la data
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    init(id: Int,
         titolo: String,
         tipo: ChatType,
         ultimoMessaggio: String? = nil,
         ultimoAggiornamento: Date? = nil,
         nonLetti: Int = 0) {
        self.id = id
        self.titolo = titolo
        self.tipo = tipo
        self.ultimoMessaggio = ultimoMessaggio
        self.ultimoAggiornamento = ultimoAggiornamento
        self.nonLetti = nonLetti
    }
}
