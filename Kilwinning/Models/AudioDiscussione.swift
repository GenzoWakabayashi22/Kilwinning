import Foundation

/// Modello dati per una discussione audio collegata a una tornata
struct AudioDiscussione: Identifiable, Codable {
    let id: Int
    var idTornata: Int // Collegamento alla tornata
    var fratelloIntervento: String
    var titoloIntervento: String
    var durata: String? // Formato: "mm:ss" o "hh:mm:ss"
    var audioURL: String // URL HTTPS di pCloud
    var dataUpload: Date
    
    var formattedUploadDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: dataUpload)
    }
    
    init(id: Int,
         idTornata: Int,
         fratelloIntervento: String,
         titoloIntervento: String,
         durata: String? = nil,
         audioURL: String,
         dataUpload: Date = Date()) {
        self.id = id
        self.idTornata = idTornata
        self.fratelloIntervento = fratelloIntervento
        self.titoloIntervento = titoloIntervento
        self.durata = durata
        self.audioURL = audioURL
        self.dataUpload = dataUpload
    }
}
