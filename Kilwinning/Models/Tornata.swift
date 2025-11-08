import Foundation

/// Tipo di tornata
enum TornataType: String, Codable, CaseIterable {
    case ordinaria = "ordinaria"
    case straordinaria = "straordinaria"
    case cerimonia = "cerimonia"
}

/// Stato della tornata
enum TornataStatus: String, Codable, CaseIterable {
    case programmata = "programmata"
    case completata = "completata"
    case annullata = "annullata"
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
    let id: Int // Changed to Int for backend compatibility
    var discussione: String // Topic/discussion (mapped to title for compatibility)
    var title: String // Kept for backward compatibility
    var data: Date // Italian naming for backend compatibility
    var date: Date // Kept for backward compatibility
    var tipo: String // Backend uses string
    var type: TornataType
    var location: String // Location as string
    var locationEnum: TornataLocation // Kept for enum support
    var introducedBy: String // Nome del fratello che introduce
    var cena: Bool // Italian naming for backend
    var hasDinner: Bool // Kept for backward compatibility
    var stato: String // Status: programmata/completata/annullata
    var status: TornataStatus // Enum version
    var notes: String?
    var coverImageURL: String? // URL immagine di copertina
    
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
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    init(id: Int,
         discussione: String? = nil,
         title: String,
         data: Date? = nil,
         date: Date,
         tipo: String? = nil,
         type: TornataType,
         location: String? = nil,
         locationEnum: TornataLocation = .tofa,
         introducedBy: String,
         cena: Bool? = nil,
         hasDinner: Bool = false,
         stato: String? = nil,
         status: TornataStatus = .programmata,
         notes: String? = nil,
         coverImageURL: String? = nil) {
        self.id = id
        self.discussione = discussione ?? title
        self.title = title
        self.data = data ?? date
        self.date = date
        self.tipo = tipo ?? type.rawValue
        self.type = type
        self.location = location ?? locationEnum.rawValue
        self.locationEnum = locationEnum
        self.introducedBy = introducedBy
        self.cena = cena ?? hasDinner
        self.hasDinner = hasDinner
        self.stato = stato ?? status.rawValue
        self.status = status
        self.notes = notes
        self.coverImageURL = coverImageURL
    }

    /// Coding keys per compatibilità con backend API
    enum CodingKeys: String, CodingKey {
        case id
        case discussione
        case title
        case data
        case date
        case tipo
        case type
        case location
        case locationEnum = "location_enum"
        case introducedBy = "introduced_by"
        case cena
        case hasDinner = "has_dinner"
        case stato
        case status
        case notes
        case coverImageURL = "cover_image_url"
    }
}
