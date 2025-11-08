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
    let id: Int // Changed to Int for backend compatibility
    var nome: String // Full name for compatibility with Node.js API
    var firstName: String
    var lastName: String
    var email: String
    var grado: String // Backend uses string representation
    var degree: MasonicDegree
    var caricaFissa: String? // Fixed charge/role
    var role: InstitutionalRole
    var isAdmin: Bool
    var registrationDate: Date
    var dataIniziazione: Date? // Initiation date
    var dataPassaggio: Date? // Passage date (Apprendista → Compagno)
    var dataElevazione: Date? // Elevation date (Compagno → Maestro)
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var displayRole: String {
        if role != .none {
            return "\(role.rawValue) – \(fullName)"
        }
        return "\(degree.rawValue) – \(fullName)"
    }
    
    init(id: Int,
         nome: String? = nil,
         firstName: String,
         lastName: String,
         email: String,
         grado: String? = nil,
         degree: MasonicDegree,
         caricaFissa: String? = nil,
         role: InstitutionalRole = .none,
         isAdmin: Bool = false,
         registrationDate: Date = Date(),
         dataIniziazione: Date? = nil,
         dataPassaggio: Date? = nil,
         dataElevazione: Date? = nil) {
        self.id = id
        self.nome = nome ?? "\(firstName) \(lastName)"
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.grado = grado ?? degree.rawValue
        self.degree = degree
        self.caricaFissa = caricaFissa
        self.role = role
        self.isAdmin = isAdmin
        self.registrationDate = registrationDate
        self.dataIniziazione = dataIniziazione
        self.dataPassaggio = dataPassaggio
        self.dataElevazione = dataElevazione
    }

    /// Coding keys per compatibilità con backend API
    enum CodingKeys: String, CodingKey {
        case id
        case nome
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case grado
        case degree
        case caricaFissa = "carica_fissa"
        case role
        case isAdmin = "admin_access"
        case registrationDate = "registration_date"
        case dataIniziazione = "data_iniziazione"
        case dataPassaggio = "data_passaggio"
        case dataElevazione = "data_elevazione"
    }
}
