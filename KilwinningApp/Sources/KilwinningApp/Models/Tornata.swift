import Foundation

/// Tipo di tornata
enum TornataType: String, Codable, CaseIterable {
    case ordinaria = "Ordinaria"
    case cerimonia = "Cerimonia"
}

/// Luogo della tornata
enum TornataLocation: String, Codable {
    case tofa = "Nostra Loggia - Tolfa"
    case visita = "Loggia in Visita"
    
    var isHome: Bool {
        self == .tofa
    }
}

/// Modello dati per una tornata (riunione della Loggia)
struct Tornata: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var type: TornataType
    var location: TornataLocation
    var introducedBy: String // Nome del fratello che introduce
    var hasDinner: Bool
    var notes: String?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    init(id: UUID = UUID(),
         title: String,
         date: Date,
         type: TornataType,
         location: TornataLocation = .tofa,
         introducedBy: String,
         hasDinner: Bool = false,
         notes: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.type = type
        self.location = location
        self.introducedBy = introducedBy
        self.hasDinner = hasDinner
        self.notes = notes
    }
}
