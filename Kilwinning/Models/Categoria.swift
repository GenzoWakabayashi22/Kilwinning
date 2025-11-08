import Foundation

/// Categoria di libri con icona e colore personalizzati
struct Categoria: Identifiable, Codable, Hashable {
    let id: Int
    var nome: String
    var icona: String // emoji o SF Symbol
    var colore: String? // hex color
    var ordinamento: Int

    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case icona
        case colore
        case ordinamento
    }

    init(id: Int,
         nome: String,
         icona: String = "📚",
         colore: String? = nil,
         ordinamento: Int = 0) {
        self.id = id
        self.nome = nome
        self.icona = icona
        self.colore = colore
        self.ordinamento = ordinamento
    }
}

/// DTO per la creazione/modifica di una categoria
struct CategoriaDTO: Codable {
    var nome: String
    var icona: String
    var colore: String?
    var ordinamento: Int
}
