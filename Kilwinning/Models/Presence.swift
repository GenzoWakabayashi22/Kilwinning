import Foundation

/// Stato di presenza del fratello
enum PresenceStatus: String, Codable {
    case presente = "Presente"
    case assente = "Assente"
    case nonConfermato = "Non Confermato"
}

/// Modello dati per la presenza di un fratello a una tornata
struct Presence: Identifiable, Codable {
    let id: Int? // Optional for new presences
    let fratelloId: Int // Backend uses Italian naming
    let brotherId: Int // Kept for compatibility
    let tornataId: Int
    var presente: Bool // Backend uses boolean
    var status: PresenceStatus
    var confirmedAt: Date?

    init(id: Int? = nil,
         fratelloId: Int? = nil,
         brotherId: Int,
         tornataId: Int,
         presente: Bool? = nil,
         status: PresenceStatus = .nonConfermato,
         confirmedAt: Date? = nil) {
        self.id = id
        self.fratelloId = fratelloId ?? brotherId
        self.brotherId = brotherId
        self.tornataId = tornataId
        self.presente = presente ?? (status == .presente)
        self.status = status
        self.confirmedAt = confirmedAt
    }

    /// Coding keys per compatibilità con backend API
    enum CodingKeys: String, CodingKey {
        case id
        case fratelloId = "fratello_id"
        case brotherId = "brother_id"
        case tornataId = "tornata_id"
        case presente
        case status
        case confirmedAt = "confirmed_at"
    }
}

/// Statistiche di presenza per un fratello
struct PresenceStatistics: Codable {
    let totaliTornate: Int // Italian naming for API compatibility
    let totalTornate: Int // Kept for compatibility
    let presenzeCount: Int // Number of presences
    let presences: Int // Kept for compatibility
    let absences: Int
    let percentuale: Int // Attendance percentage (0-100)
    let presenzeConsecutive: Int // Consecutive presences
    let consecutivePresences: Int // Kept for compatibility
    let personalRecord: Int
    let attendanceRate: Double

    var formattedAttendanceRate: String {
        String(format: "%.0f%%", attendanceRate * 100)
    }

    init(totaliTornate: Int? = nil,
         totalTornate: Int,
         presenzeCount: Int? = nil,
         presences: Int,
         absences: Int,
         percentuale: Int? = nil,
         presenzeConsecutive: Int,
         consecutivePresences: Int? = nil,
         personalRecord: Int) {
        self.totaliTornate = totaliTornate ?? totalTornate
        self.totalTornate = totalTornate
        self.presenzeCount = presenzeCount ?? presences
        self.presences = presences
        self.absences = absences
        self.percentuale = percentuale ?? Int((Double(presences) / Double(totalTornate)) * 100)
        self.presenzeConsecutive = presenzeConsecutive
        self.consecutivePresences = consecutivePresences ?? presenzeConsecutive
        self.personalRecord = personalRecord
        self.attendanceRate = totalTornate > 0 ? Double(presences) / Double(totalTornate) : 0
    }

    /// Coding keys per compatibilità con backend API
    enum CodingKeys: String, CodingKey {
        case totaliTornate = "totali_tornate"
        case totalTornate = "total_tornate"
        case presenzeCount = "presenze_count"
        case presences
        case absences
        case percentuale
        case presenzeConsecutive = "presenze_consecutive"
        case consecutivePresences = "consecutive_presences"
        case personalRecord = "personal_record"
        case attendanceRate = "attendance_rate"
    }
}
