import Foundation

/// Stato di una tavola architettonica
enum TavolaStatus: String, Codable, CaseIterable {
    case completata = "Completata"
    case programmato = "Programmato"
    case inPreparazione = "In Preparazione"
}

/// Modello dati per una tavola architettonica
struct Tavola: Identifiable, Codable {
    let id: UUID
    let brotherId: UUID
    var title: String
    var presentationDate: Date?
    var status: TavolaStatus
    var content: String?
    var createdAt: Date
    
    var formattedPresentationDate: String? {
        guard let date = presentationDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    init(id: UUID = UUID(),
         brotherId: UUID,
         title: String,
         presentationDate: Date? = nil,
         status: TavolaStatus = .inPreparazione,
         content: String? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.brotherId = brotherId
        self.title = title
        self.presentationDate = presentationDate
        self.status = status
        self.content = content
        self.createdAt = createdAt
    }
}
