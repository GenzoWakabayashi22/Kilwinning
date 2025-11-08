import Foundation

/// Grado massonico del fratello
enum MasonicDegree: String, Codable, CaseIterable {
    case apprendista = "Apprendista"
    case compagno = "Compagno"
    case maestro = "Maestro"
}

/// Ruolo istituzionale del fratello
enum InstitutionalRole: String, Codable, CaseIterable {
    case none = "Nessuno"
    case venerabileMaestro = "Ven.mo Maestro"
    case primoSorvegliante = "1° Sorvegliante"
    case secondoSorvegliante = "2° Sorvegliante"
    case oratore = "Oratore"
    case segretario = "Segretario"
    case tesoriere = "Tesoriere"
    case ospitaliere = "Ospitaliere"
    case maestroCerimonie = "Maestro delle Cerimonie"
    case copritoreInterno = "Copritore Interno"
    case copritoreEsterno = "Copritore Esterno"
}

/// Modello dati per un fratello della Loggia
struct Brother: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var degree: MasonicDegree
    var role: InstitutionalRole
    var isAdmin: Bool
    var registrationDate: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var displayRole: String {
        if role != .none {
            return "\(role.rawValue) – \(fullName)"
        }
        return "\(degree.rawValue) – \(fullName)"
    }
    
    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         email: String,
         degree: MasonicDegree,
         role: InstitutionalRole = .none,
         isAdmin: Bool = false,
         registrationDate: Date = Date()) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.degree = degree
        self.role = role
        self.isAdmin = isAdmin
        self.registrationDate = registrationDate
    }
}
