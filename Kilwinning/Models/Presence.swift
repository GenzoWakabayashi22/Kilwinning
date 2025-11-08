import Foundation

/// Stato di presenza del fratello
enum PresenceStatus: String, Codable {
    case presente = "Presente"
    case assente = "Assente"
    case nonConfermato = "Non Confermato"
}

/// Modello dati per la presenza di un fratello a una tornata
struct Presence: Identifiable, Codable {
    let id: UUID
    let brotherId: UUID
    let tornataId: UUID
    var status: PresenceStatus
    var confirmedAt: Date?
    
    init(id: UUID = UUID(),
         brotherId: UUID,
         tornataId: UUID,
         status: PresenceStatus = .nonConfermato,
         confirmedAt: Date? = nil) {
        self.id = id
        self.brotherId = brotherId
        self.tornataId = tornataId
        self.status = status
        self.confirmedAt = confirmedAt
    }
}

/// Statistiche di presenza per un fratello
struct PresenceStatistics {
    let totalTornate: Int
    let presences: Int
    let absences: Int
    let consecutivePresences: Int
    let personalRecord: Int
    let attendanceRate: Double
    
    var formattedAttendanceRate: String {
        String(format: "%.0f%%", attendanceRate * 100)
    }
    
    init(totalTornate: Int, presences: Int, absences: Int, consecutivePresences: Int, personalRecord: Int) {
        self.totalTornate = totalTornate
        self.presences = presences
        self.absences = absences
        self.consecutivePresences = consecutivePresences
        self.personalRecord = personalRecord
        self.attendanceRate = totalTornate > 0 ? Double(presences) / Double(totalTornate) : 0
    }
}
