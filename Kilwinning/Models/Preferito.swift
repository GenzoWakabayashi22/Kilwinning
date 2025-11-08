import Foundation

/// Preferito biblioteca - relazione fratello-libro
struct PreferitoBiblioteca: Identifiable, Codable {
    let id: Int
    var fratelloId: Int
    var libroId: Int
    var dataAggiunta: Date

    enum CodingKeys: String, CodingKey {
        case id
        case fratelloId = "fratello_id"
        case libroId = "libro_id"
        case dataAggiunta = "data_aggiunta"
    }

    init(id: Int,
         fratelloId: Int,
         libroId: Int,
         dataAggiunta: Date = Date()) {
        self.id = id
        self.fratelloId = fratelloId
        self.libroId = libroId
        self.dataAggiunta = dataAggiunta
    }
}

/// DTO per toggle preferito (solo libroId, fratelloId implicito da auth)
struct TogglePreferitoDTO: Codable {
    var libroId: Int

    enum CodingKeys: String, CodingKey {
        case libroId = "libro_id"
    }
}
