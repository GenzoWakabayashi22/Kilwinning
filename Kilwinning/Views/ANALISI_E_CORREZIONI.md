# 📋 ANALISI COMPLETA DEL PROGETTO KILWINNING
## Problemi Identificati e Soluzioni

---

## ✅ PROBLEMI CRITICI RISOLTI

### 1. **Errore: `location.isHome` su String**
**Problema**: In `TornateListView.swift` e `TornataDetailView.swift`, si usava `tornata.location.isHome` invece di `tornata.locationEnum.isHome`
- ❌ Errore: `Value of type 'String' has no member 'isHome'`
- ✅ **RISOLTO**: Cambiato in `tornata.locationEnum.isHome` e `tornata.locationEnum.rawValue`

### 2. **Incompatibilità ID: Int vs UUID**
**Problema**: Il backend usa ID `Int`, ma alcuni modelli usavano `UUID`
- ✅ **RISOLTO**: 
  - `Tornata.id` ora usa `Int` (compatibile con backend)
  - `AudioDiscussione.idTornata` usa `Int` invece di `UUID`
  - Aggiunto convertitore DTO in `AudioService`

---

## ⚠️ PROBLEMI DA RISOLVERE URGENTEMENTE

### 🔴 1. **MODELLI MANCANTI - BLOCCANTE**

Il progetto riferisce diversi modelli che non ho potuto visualizzare. Servono questi file:

#### **Brother.swift** - Modello Fratello
```swift
import Foundation

enum MasonicDegree: String, Codable, CaseIterable {
    case apprendista = "Apprendista"
    case compagno = "Compagno d'Arte"
    case maestro = "Maestro"
}

enum InstitutionalRole: String, Codable, CaseIterable {
    case none = "Nessuna carica"
    case venerabileMaestro = "Venerabile Maestro"
    case primoSorvegliante = "Primo Sorvegliante"
    case secondoSorvegliante = "Secondo Sorvegliante"
    case oratore = "Oratore"
    case segretario = "Segretario"
    case tesoriere = "Tesoriere"
    case ospitaliere = "Ospitaliere"
    case maestroCerimonie = "Maestro delle Cerimonie"
    case copritoreEsterno = "Copritore Esterno"
    case esperto = "Esperto"
}

struct Brother: Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var degree: MasonicDegree
    var role: InstitutionalRole
    var isAdmin: Bool
    var photoURL: String?
    var phoneNumber: String?
    var initiationDate: Date?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var formattedFullName: String {
        "Fr. \(firstName) \(lastName)"
    }
    
    init(id: UUID = UUID(),
         firstName: String,
         lastName: String,
         email: String,
         degree: MasonicDegree,
         role: InstitutionalRole,
         isAdmin: Bool,
         photoURL: String? = nil,
         phoneNumber: String? = nil,
         initiationDate: Date? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.degree = degree
        self.role = role
        self.isAdmin = isAdmin
        self.photoURL = photoURL
        self.phoneNumber = phoneNumber
        self.initiationDate = initiationDate
    }
}
```

#### **Presence.swift** - Modello Presenza
```swift
import Foundation

enum PresenceStatus: String, Codable, CaseIterable {
    case presente = "Presente"
    case assente = "Assente"
    case nonConfermato = "Non Confermato"
}

struct Presence: Identifiable, Codable {
    let id: UUID
    var brotherId: UUID
    var tornataId: Int // Changed to Int for backend compatibility
    var status: PresenceStatus
    var confirmedAt: Date?
    
    init(id: UUID = UUID(),
         brotherId: UUID,
         tornataId: Int,
         status: PresenceStatus,
         confirmedAt: Date? = nil) {
        self.id = id
        self.brotherId = brotherId
        self.tornataId = tornataId
        self.status = status
        self.confirmedAt = confirmedAt
    }
}

struct PresenceStatistics {
    var totalTornate: Int
    var presences: Int
    var absences: Int
    var consecutivePresences: Int
    var personalRecord: Int
    
    var presencePercentage: Double {
        guard totalTornate > 0 else { return 0 }
        return Double(presences) / Double(totalTornate) * 100
    }
}
```

#### **MessaggioChat.swift** - Modello Messaggio Chat
```swift
import Foundation

enum MessaggioStato: String, Codable {
    case inviato = "Inviato"
    case ricevuto = "Ricevuto"
    case letto = "Letto"
}

struct MessaggioChat: Identifiable, Codable {
    let id: Int
    var idChat: Int
    var idMittente: UUID
    var testo: String
    var timestamp: Date
    var stato: MessaggioStato
    
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.locale = Locale(identifier: "it_IT")
        
        if Calendar.current.isDateInToday(timestamp) {
            return formatter.string(from: timestamp)
        } else {
            formatter.dateStyle = .short
            return formatter.string(from: timestamp)
        }
    }
}
```

#### **Tavola.swift** - Modello Tavola (Scrittura Massonica)
```swift
import Foundation

struct Tavola: Identifiable, Codable {
    let id: UUID
    var brotherId: UUID
    var title: String
    var content: String
    var date: Date
    var category: String?
    var isPublic: Bool // Se la tavola è visibile a tutti i fratelli
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "it_IT")
        return formatter.string(from: date)
    }
    
    init(id: UUID = UUID(),
         brotherId: UUID,
         title: String,
         content: String,
         date: Date = Date(),
         category: String? = nil,
         isPublic: Bool = false) {
        self.id = id
        self.brotherId = brotherId
        self.title = title
        self.content = content
        self.date = date
        self.category = category
        self.isPublic = isPublic
    }
}
```

#### **AppConstants.swift** - Costanti dell'App
```swift
import Foundation

struct AppConstants {
    struct API {
        static let baseURL = "https://your-api-domain.com/api/"
        static let timeout: TimeInterval = 30.0
    }
    
    struct Demo {
        static let email = "prova@kilwinning.it"
        static let password = "prova123"
    }
    
    struct Cache {
        static let statisticsCacheDuration: TimeInterval = 300 // 5 minuti
    }
}
```

#### **Color+Extensions.swift** - Estensioni Colori
```swift
import SwiftUI

extension Color {
    static let appBackground = Color("AppBackground")
    static let appSecondaryBackground = Color("AppSecondaryBackground")
    static let appGray = Color.gray
}
```

---

## 🔴 2. **CHAT SYSTEM - PROBLEMI CRITICI**

### Problema: **Mappatura ID Brother (UUID ↔ Int)**
**Impatto**: La chat non può identificare correttamente i mittenti

**Nel file `ChatService.swift`**:
```swift
// PROBLEMA ATTUALE - Riga 167-172
print("Warning: Creating MessaggioChat with random UUID. Proper ID mapping needed.")

return MessaggioChat(
    id: dto.id,
    idChat: dto.id_chat,
    idMittente: UUID(), // ❌ CREA UUID CASUALE!
    testo: dto.testo,
    timestamp: timestamp,
    stato: stato
)
```

**SOLUZIONE NECESSARIA**:
1. Creare una tabella di mappatura `Int` (backend) → `UUID` (frontend)
2. Oppure modificare il backend per usare UUID
3. Oppure modificare il frontend per usare Int ovunque

**IMPLEMENTAZIONE CONSIGLIATA - BrotherMappingService.swift**:
```swift
import Foundation

/// Servizio per mappare ID fratelli tra backend (Int) e frontend (UUID)
@MainActor
class BrotherMappingService: ObservableObject {
    private var intToUUID: [Int: UUID] = [:]
    private var uuidToInt: [UUID: Int] = [:]
    
    func registerBrother(backendId: Int, frontendId: UUID) {
        intToUUID[backendId] = frontendId
        uuidToInt[frontendId] = backendId
    }
    
    func getUUID(for backendId: Int) -> UUID? {
        return intToUUID[backendId]
    }
    
    func getBackendId(for uuid: UUID) -> Int? {
        return uuidToInt[uuid]
    }
    
    // Carica mappature dal backend o database locale
    func loadMappings() async {
        // TODO: Implementare caricamento da backend
    }
}
```

### Problema: **Nome mittente non mostrato**
In `ChatView.swift`, il messaggio mostra solo il testo, non chi l'ha scritto.

**SOLUZIONE**:
```swift
// In MessageBubble, aggiungi:
struct MessageBubble: View {
    let messaggio: MessaggioChat
    let isCurrentUser: Bool
    let senderName: String // NUOVO
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // NUOVO: Mostra nome mittente
                if !isCurrentUser {
                    Text(senderName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppTheme.masonicBlue)
                }
                
                Text(messaggio.testo)
                    .font(.body)
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isCurrentUser ? AppTheme.masonicBlue : Color.appSecondaryBackground)
                    .cornerRadius(18)
                
                // ... resto del codice
            }
            
            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
}
```

### Problema: **Chat dirette tra due fratelli non implementate**
Attualmente esiste solo la chat di gruppo.

**SOLUZIONE**:
```swift
// In ChatService.swift, aggiungi:
func createDirectChat(brotherId: UUID, otherBrotherId: UUID) async {
    // Verifica se esiste già una chat tra questi due fratelli
    let existingChat = chatRooms.first { room in
        room.tipo == .singola && 
        room.titolo.contains(otherBrotherId.uuidString) // Logica migliorabile
    }
    
    if existingChat == nil {
        // Crea nuova chat diretta
        let newId = (chatRooms.map { $0.id }.max() ?? 0) + 1
        let newChat = ChatRoom(
            id: newId,
            titolo: "Chat diretta", // Nome da recuperare dal Brother
            tipo: .singola
        )
        
        // TODO: Chiamata API per creare chat nel backend
        chatRooms.append(newChat)
    }
}
```

---

## 🟡 3. **TORNATE - MIGLIORAMENTI NECESSARI**

### Problema: **Inizializzatore Tornata complesso**
L'inizializzatore con 16 parametri (molti opzionali) è difficile da usare.

**SOLUZIONE**:
```swift
// Aggiungi convenience initializer in Tornata.swift
extension Tornata {
    /// Inizializzatore semplificato per creazione frontend
    static func create(
        title: String,
        date: Date,
        type: TornataType,
        locationEnum: TornataLocation,
        introducedBy: String,
        hasDinner: Bool = false,
        notes: String? = nil
    ) -> Tornata {
        return Tornata(
            id: 0, // Il backend assegnerà l'ID reale
            title: title,
            date: date,
            type: type,
            locationEnum: locationEnum,
            introducedBy: introducedBy,
            hasDinner: hasDinner,
            notes: notes
        )
    }
}
```

### Problema: **Preview non funziona correttamente**
Nel preview di `TornataDetailView.swift` manca `id`:

**CORREZIONE**:
```swift
#Preview {
    TornataDetailView(
        tornata: Tornata(
            id: 1, // AGGIUNTO
            title: "Il sentiero della saggezza",
            date: Date(),
            type: .ordinaria,
            locationEnum: .tofa, // CORRETTO
            introducedBy: "Fr. Marco Rossi",
            hasDinner: true,
            notes: "Tornata con discussione sul simbolismo della squadra e del compasso"
        ),
        brother: Brother(
            firstName: "Paolo Giulio",
            lastName: "Gazzano",
            email: "demo@kilwinning.it",
            degree: .maestro,
            role: .venerabileMaestro,
            isAdmin: true
        )
    )
}
```

---

## 🟡 4. **PRESENZE - INCONSISTENZA DATI**

### Problema: **Mismatch UUID vs Int per tornataId**
- `Presence.tornataId` deve essere `Int` per compatibilità backend
- `DataService` deve gestire correttamente la conversione

**GIÀ CORRETTO** parzialmente, ma verifica:
```swift
// In DataService.swift, assicurati che:
func getPresenceStatus(brotherId: UUID, tornataId: Int) -> PresenceStatus {
    // Deve usare Int, non UUID
    presenzeRepository.getPresenceStatus(brotherId: brotherId, tornataId: tornataId)
}
```

---

## 🟡 5. **BIBLIOTECA - FUNZIONALITÀ MANCANTE**

La sezione biblioteca sembra implementata nel backend ma non ho trovato le view.

**FILE NECESSARI**:
- `BibliotecaView.swift` - Lista libri
- `LibroDetailView.swift` - Dettaglio libro
- `PrestitiView.swift` - Lista prestiti attivi

**ESEMPIO - BibliotecaView.swift**:
```swift
import SwiftUI

struct BibliotecaView: View {
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var viewModel = BibliotecaViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                SearchBar(text: $searchText)
                
                // Lista libri
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.filteredBooks(searchText: searchText)) { libro in
                                LibroCard(libro: libro) {
                                    viewModel.selectBook(libro)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Biblioteca")
            .task {
                await viewModel.fetchLibri()
            }
        }
    }
}
```

---

## 🟡 6. **ADMIN PANEL - GESTIONE BACKEND MANCANTE**

### Funzionalità Admin Necessarie:
1. ✅ **Creazione tornate** (da implementare UI)
2. ✅ **Modifica tornate** (da implementare UI)
3. ✅ **Eliminazione tornate** (da implementare UI)
4. ❌ **Gestione fratelli** (Backend API esiste?)
5. ❌ **Gestione cariche** (Backend API esiste?)
6. ✅ **Gestione biblioteca** (Backend API esiste)
7. ❌ **Upload audio discussioni**
8. ❌ **Gestione chat rooms**

**FILE DA CREARE**:
- `AdminView.swift` - Dashboard admin
- `AdminTornateView.swift` - CRUD tornate
- `AdminFratelliView.swift` - Gestione fratelli
- `AdminCaricheView.swift` - Assegnazione cariche
- `AdminBibliotecaView.swift` - Gestione libri
- `AdminChatView.swift` - Gestione chat rooms

---

## 🟢 7. **REPOSITORIES MANCANTI**

Il progetto usa il pattern Repository ma mancano implementazioni:

**FILE NECESSARI**:

### **TornateRepository.swift**
```swift
import Foundation

protocol TornateRepositoryProtocol {
    func fetchTornate() async throws -> [Tornata]
    func createTornata(_ tornata: Tornata) async throws
    func updateTornata(_ tornata: Tornata) async throws
    func deleteTornata(_ tornata: Tornata) async throws
}

class TornateRepository: TornateRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchTornate() async throws -> [Tornata] {
        let dtos = try await networkService.fetchTornate()
        return dtos.map { convertToTornata(from: $0) }
    }
    
    func createTornata(_ tornata: Tornata) async throws {
        // TODO: Implementare POST al backend
    }
    
    func updateTornata(_ tornata: Tornata) async throws {
        // TODO: Implementare PUT al backend
    }
    
    func deleteTornata(_ tornata: Tornata) async throws {
        // TODO: Implementare DELETE al backend
    }
    
    private func convertToTornata(from dto: TornataDTO) -> Tornata {
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: dto.data_tornata) ?? Date()
        
        return Tornata(
            id: dto.id,
            title: dto.titolo,
            date: date,
            type: TornataType(rawValue: dto.tipo) ?? .ordinaria,
            location: dto.luogo,
            locationEnum: TornataLocation(rawValue: dto.luogo) ?? .tofa,
            introducedBy: dto.presentato_da ?? "Sconosciuto",
            hasDinner: dto.ha_agape == 1,
            notes: dto.note
        )
    }
}
```

### **PresenzeRepository.swift**
```swift
import Foundation

protocol PresenzeRepositoryProtocol {
    func fetchPresenze() async throws -> [Presence]
    func updatePresence(brotherId: UUID, tornataId: Int, status: PresenceStatus) async throws
    func getPresenceStatus(brotherId: UUID, tornataId: Int) -> PresenceStatus
}

class PresenzeRepository: PresenzeRepositoryProtocol {
    private let networkService: NetworkService
    private var localPresences: [Presence] = []
    
    init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchPresenze() async throws -> [Presence] {
        // TODO: Implementare fetch da backend
        // Per ora ritorna cache locale
        return localPresences
    }
    
    func updatePresence(brotherId: UUID, tornataId: Int, status: PresenceStatus) async throws {
        // TODO: Chiamata API backend
        
        // Aggiorna cache locale
        if let index = localPresences.firstIndex(where: { 
            $0.brotherId == brotherId && $0.tornataId == tornataId 
        }) {
            localPresences[index].status = status
            localPresences[index].confirmedAt = Date()
        } else {
            localPresences.append(Presence(
                brotherId: brotherId,
                tornataId: tornataId,
                status: status,
                confirmedAt: Date()
            ))
        }
    }
    
    func getPresenceStatus(brotherId: UUID, tornataId: Int) -> PresenceStatus {
        localPresences.first(where: { 
            $0.brotherId == brotherId && $0.tornataId == tornataId 
        })?.status ?? .nonConfermato
    }
}
```

### **AppEnvironment.swift**
```swift
import Foundation

/// Dependency injection container
class AppEnvironment {
    static let shared = AppEnvironment()
    
    let networkService: NetworkService
    let tornateRepository: TornateRepositoryProtocol
    let presenzeRepository: PresenzeRepositoryProtocol
    
    private init() {
        self.networkService = NetworkService()
        self.tornateRepository = TornateRepository(networkService: networkService)
        self.presenzeRepository = PresenzeRepository(networkService: networkService)
    }
}
```

---

## 🟢 8. **VIEW UTILITIES MANCANTI**

### **CommonViews.swift**
```swift
import SwiftUI

// Empty State
struct EmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Info Row
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// Presence Button
struct PresenceButton: View {
    let status: PresenceStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: status == .presente ? "checkmark.circle.fill" : "xmark.circle.fill")
                Text(status.rawValue)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : .primary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? statusColor : Color.appSecondaryBackground)
            .cornerRadius(12)
        }
    }
    
    private var statusColor: Color {
        status == .presente ? AppTheme.success : AppTheme.error
    }
}

// Search Bar
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Cerca", text: $text)
                .textFieldStyle(.plain)
        }
        .padding()
        .background(Color.appSecondaryBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// Audio Player View (placeholder)
struct AudioPlayerView: View {
    let audioURL: String
    let titolo: String
    let fratello: String
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // TODO: Implementare player audio reale
                Image(systemName: "music.note")
                    .font(.system(size: 80))
                    .foregroundColor(AppTheme.masonicBlue)
                
                Text(titolo)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Fr. \(fratello)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Placeholder controls
                HStack(spacing: 30) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 50))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
                            .font(.title)
                    }
                }
                .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Audio Player")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Chiudi") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

---

## 📊 RIEPILOGO PRIORITÀ

### 🔴 URGENTE (Blocca funzionalità)
1. Creare modelli mancanti: `Brother`, `Presence`, `MessaggioChat`, `Tavola`
2. Risolvere mappatura ID chat (UUID ↔ Int)
3. Implementare repositories (`TornateRepository`, `PresenzeRepository`)
4. Creare `AppConstants.swift` e `Color+Extensions.swift`

### 🟡 IMPORTANTE (Funzionalità incomplete)
5. Mostrare nome mittente nei messaggi chat
6. Implementare chat dirette tra fratelli
7. Creare sezione Biblioteca con UI
8. Creare pannello Admin per gestione backend

### 🟢 MIGLIORAMENTI (Nice to have)
9. Semplificare inizializzatore `Tornata`
10. Aggiungere audio player funzionante
11. Implementare gestione cariche
12. Aggiungere notifiche push

---

## 🚀 PROSSIMI PASSI CONSIGLIATI

1. **Creare tutti i modelli mancanti** (Brother, Presence, MessaggioChat, Tavola)
2. **Implementare BrotherMappingService** per chat funzionante
3. **Creare CommonViews.swift** con componenti riutilizzabili
4. **Implementare repositories mancanti**
5. **Creare BibliotecaView** e relative view
6. **Creare AdminView** per gestione backend
7. **Testing completo** di ogni funzionalità
8. **Documentazione API** per comunicazione con backend

---

## 📝 NOTE FINALI

### Backend API Endpoints (da documentare):
- ✅ `GET tornate.php` - Funziona
- ✅ `GET presenze.php` - Funziona
- ✅ `POST presenze.php` - Funziona
- ✅ `GET libri.php` - Funziona
- ✅ `GET prestiti.php` - Funziona
- ✅ `POST prestiti.php` - Funziona
- ✅ `GET audio_discussioni.php` - Funziona
- ✅ `GET chat.php?rooms=1` - Funziona
- ✅ `GET chat.php?id_chat=X` - Funziona
- ✅ `POST chat.php` - Funziona
- ❓ `POST tornate.php` - Da verificare (create)
- ❓ `PUT tornate.php` - Da verificare (update)
- ❓ `DELETE tornate.php` - Da verificare (delete)
- ❓ `GET fratelli.php` - Da implementare?
- ❓ `POST fratelli.php` - Da implementare?

### Configurazione Required:
- File `Config.plist` con chiave `API_BASE_URL`
- Asset Catalog con colori personalizzati:
  - `AppBackground`
  - `AppSecondaryBackground`

Hai bisogno di aiuto per implementare una di queste soluzioni? Posso creare i file mancanti o correggere problemi specifici!
