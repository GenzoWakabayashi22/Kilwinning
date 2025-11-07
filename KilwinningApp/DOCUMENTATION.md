# Documentazione Tecnica - Sistema Gestione Tornate Kilwinning

## Architettura dell'App

### Pattern MVVM (Model-View-ViewModel)

L'app segue il pattern MVVM separando:
- **Models**: Strutture dati pure (Brother, Tornata, Presence, Tavola)
- **Views**: Interfacce SwiftUI dichiarative
- **Services**: Logica business e gestione dati (AuthenticationService, DataService)

### Flusso dei Dati

```
User Input → View → Service (@Published) → View Update
```

I Services utilizzano `@Published` properties che triggherano automaticamente aggiornamenti UI quando cambiano.

## Modelli Dati

### Brother (Fratello)
```swift
struct Brother {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var degree: MasonicDegree  // Apprendista, Compagno, Maestro
    var role: InstitutionalRole // Ruolo istituzionale
    var isAdmin: Bool
    var registrationDate: Date
}
```

### Tornata (Riunione)
```swift
struct Tornata {
    let id: UUID
    var title: String
    var date: Date
    var type: TornataType  // Ordinaria, Cerimonia
    var location: TornataLocation  // Tofa, Visita
    var introducedBy: String
    var hasDinner: Bool
    var notes: String?
}
```

### Presence (Presenza)
```swift
struct Presence {
    let id: UUID
    let brotherId: UUID
    let tornataId: UUID
    var status: PresenceStatus  // Presente, Assente, NonConfermato
    var confirmedAt: Date?
}
```

### Tavola (Tavola Architettonica)
```swift
struct Tavola {
    let id: UUID
    let brotherId: UUID
    var title: String
    var presentationDate: Date?
    var status: TavolaStatus  // Completata, Programmato, InPreparazione
    var content: String?
    var createdAt: Date
}
```

## Services

### AuthenticationService
Gestisce l'autenticazione degli utenti:

**Funzionalità:**
- `login(email:password:)` - Login utente
- `register()` - Registrazione nuovo fratello
- `logout()` - Logout utente
- `resetPassword()` - Recupero password

**Stato:**
- `@Published var currentBrother: Brother?`
- `@Published var isAuthenticated: Bool`
- `@Published var isLoading: Bool`

**Sessione:**
Utilizza `UserDefaults` per persistenza base. Per produzione, considerare Keychain.

### NetworkService
Gestisce tutte le chiamate HTTP al backend PHP:

**Funzionalità:**
- Generic async/await HTTP methods (GET, POST, DELETE)
- Automatic JSON encoding/decoding with ISO8601 date handling
- Error handling with custom NetworkError enum
- Configuration via Config.plist
- DTO models for API communication

**Endpoints supportati:**
- Tornate: `fetchTornate()`, `fetchTornata(id:)`
- Presenze: `fetchPresenze(fratelloId:)`, `updatePresenza(...)`
- Library: `fetchLibri()`, `fetchPrestiti(fratelloId:)`, `createPrestito(...)`, `closePrestito(...)`
- Audio: `fetchAudioDiscussioni(tornataId:)`
- Chat: `fetchChatRooms()`, `fetchChatMessages(chatId:)`, `sendMessage(...)`

**Configurazione:**
L'URL base dell'API è definito in `Config.plist`:
```xml
<key>API_BASE_URL</key>
<string>https://loggiakilwinning.com/api/</string>
```

### DataService
Gestisce tutti i dati dell'app con supporto per live backend e fallback a mock data:

**Funzionalità:**
- Gestione Tornate (CRUD)
- Gestione Presenze
- Calcolo statistiche
- Gestione Tavole
- Sincronizzazione con backend via NetworkService
- Fallback automatico a mock data in caso di errori di rete

**Stato:**
- `@Published var tornate: [Tornata]`
- `@Published var presences: [Presence]`
- `@Published var tavole: [Tavola]`
- `@Published var brothers: [Brother]`

**Conversione DTO:**
Il servizio converte automaticamente i DTOs dal backend ai modelli Swift dell'app.

### LibraryService
Gestisce la biblioteca con integrazione backend:

**Funzionalità:**
- Fetch libri dal backend con filtri
- Gestione prestiti con sincronizzazione automatica
- Fallback a mock data offline
- Aggiornamento automatico dello stato dei libri

### AudioService
Gestisce le discussioni audio:

**Funzionalità:**
- Fetch discussioni audio per tornata
- Mock data per offline use

### ChatService
Gestisce il sistema di messaggistica:

**Funzionalità:**
- Fetch chat rooms dal backend
- Gestione messaggi real-time
- Invio messaggi con sincronizzazione
- Fallback a mock data offline

## Network Layer Architecture

### DTO Models
Data Transfer Objects per comunicazione con il backend:
- `TornataDTO`: Rappresentazione tornata dal database
- `PresenzaDTO`: Dati presenza fratello
- `LibroDTO`: Informazioni libro
- `PrestitoDTO`: Dettagli prestito
- `AudioDiscussioneDTO`: Discussione audio
- `ChatRoomDTO` / `ChatMessageDTO`: Sistema messaggi

### Error Handling
```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case encodingError(Error)
    case noData
}
```

Tutti i servizi implementano try-catch con fallback a mock data:
```swift
do {
    let data = try await networkService.fetch()
    // Use live data
} catch {
    print("Error: \(error). Using mock data.")
    // Use mock data
}
```

## Views Principali

### LoginView
- Form di login
- Link a registrazione e recupero password
- Integrazione con AuthenticationService

### DashboardView
- Container principale post-login
- NavigationTabBar per navigazione tra sezioni
- BrotherHeaderView con info utente

### HomeContentView
- Tre card principali: Grado/Ruolo, Statistiche, Tornate
- Sezione prossime tornate
- Informazioni loggia

### TornateListView
- Elenco completo tornate
- Filtri per anno e tipo
- Dettagli tornata con sheet

### PresenzeView
- Statistiche presenze
- Grafico mensile (iOS 16+ con Charts framework)
- Lista ultime tornate
- Record personali

### TavoleView
- Lista tavole del fratello
- Filtro per anno
- Dettagli tavola

### AdministrationView
- Gestione utenti
- Creazione tornate
- Statistiche loggia
- Generazione report (placeholder)

## Tema e Design

### AppTheme
Definisce tutti i colori e stili dell'app:

```swift
// Colori principali
static let masonicBlue = Color(red: 0.2, green: 0.4, blue: 0.7)
static let masonicGold = Color(red: 0.85, green: 0.65, blue: 0.13)
static let white = Color.white
```

**Modificatori personalizzati:**
- `cardStyle()` - Stile card con ombra
- `sectionHeaderStyle()` - Stile header sezione

## Compatibilità Multi-Piattaforma

L'app utilizza compilation conditionals per adattarsi a iOS e macOS:

```swift
#if os(macOS)
    // Layout macOS (3 colonne)
#else
    // Layout iOS (verticale)
#endif
```

## Stati e Lifecycle

### App Lifecycle
```
App Launch → ContentView → LoginView/DashboardView
```

### Authentication Flow
```
LoginView → AuthService.login() → Dashboard (se successo)
```

### Data Flow
```
View onAppear → Service.fetch() → @Published update → View refresh
```

## Gestione Errori

Tutti i services utilizzano `async/throws` per gestione errori:

```swift
do {
    try await authService.login(email: email, password: password)
} catch {
    // Mostra alert con errore
    showError = true
}
```

## Testing

### Unit Tests
Test per modelli e logica business:
- `BrotherTests` - Test modello Brother
- `TornataTests` - Test modello Tornata
- `PresenceTests` - Test modello Presence e statistiche

### Preview
Ogni view include SwiftUI preview per sviluppo rapido:

```swift
#Preview {
    DashboardView()
}
```

## Integrazione Backend

### REST API Backend

L'app si connette a un backend PHP MySQL per tutti i dati live:

**Base URL:** `https://loggiakilwinning.com/api/`  
Configurato in: `Config.plist`

### API Endpoints

#### Tornate
```swift
// GET /api/tornate.php
let tornate = try await networkService.fetchTornate()

// GET /api/tornate.php?id=1
let tornata = try await networkService.fetchTornata(id: 1)
```

**Response Example:**
```json
{
  "success": true,
  "data": [{
    "id": 1,
    "titolo": "Il sentiero della saggezza",
    "data_tornata": "2025-11-25T19:30:00Z",
    "tipo": "Ordinaria",
    "luogo": "Nostra Loggia - Tolfa",
    "presentato_da": "Fr. Marco Rossi",
    "ha_agape": 1,
    "note": null
  }]
}
```

#### Presenze
```swift
// GET /api/presenze.php?id_fratello=1
let presenze = try await networkService.fetchPresenze(fratelloId: 1)

// POST /api/presenze.php
try await networkService.updatePresenza(
    fratelloId: 1,
    tornataId: 5,
    stato: "Presente"
)
```

#### Library
```swift
// GET /api/libri.php
let libri = try await networkService.fetchLibri()

// GET /api/prestiti.php?id_fratello=1
let prestiti = try await networkService.fetchPrestiti(fratelloId: 1)

// POST /api/prestiti.php
try await networkService.createPrestito(libroId: 3, fratelloId: 1)

// POST /api/prestiti.php (close loan)
try await networkService.closePrestito(prestitoId: 10)
```

#### Audio Discussions
```swift
// GET /api/audio_discussioni.php?id_tornata=1
let audio = try await networkService.fetchAudioDiscussioni(tornataId: 1)
```

#### Chat
```swift
// GET /api/chat.php?rooms=1
let rooms = try await networkService.fetchChatRooms()

// GET /api/chat.php?id_chat=1
let messages = try await networkService.fetchChatMessages(chatId: 1)

// POST /api/chat.php
try await networkService.sendMessage(
    chatId: 1,
    mittenteId: 1,
    testo: "Messaggio di test"
)
```

### Offline Support

Tutti i servizi implementano fallback automatico a mock data:

```swift
func fetchTornate() async {
    do {
        let dtos = try await networkService.fetchTornate()
        tornate = dtos.compactMap { convertToTornata(from: $0) }
        useMockData = false
    } catch {
        print("Error fetching from API: \(error). Using mock data.")
        useMockData = true
        // Mock data already loaded in init
    }
}
```

### Data Conversion

I DTOs dal backend vengono convertiti ai modelli Swift:

```swift
private func convertToTornata(from dto: TornataDTO) -> Tornata? {
    let dateFormatter = ISO8601DateFormatter()
    guard let date = dateFormatter.date(from: dto.data_tornata) else {
        return nil
    }
    
    return Tornata(
        title: dto.titolo,
        date: date,
        type: dto.tipo == "Ordinaria" ? .ordinaria : .cerimonia,
        location: dto.luogo.contains("Tolfa") ? .tofa : .visita,
        introducedBy: dto.presentato_da ?? "",
        hasDinner: dto.ha_agape == 1,
        notes: dto.note
    )
}
```

### Authentication & Authorization

**Current Status:** Not yet implemented  
**Future Implementation:** JWT tokens or session-based auth with PHP backend

### Known Limitations

1. **UUID to Int ID Mapping:** L'app usa UUID per gli ID locali, ma il backend usa Int. Richiede un sistema di mapping quando la gestione utenti sarà implementata.

2. **Real-time Updates:** Le chat non sono real-time. Implementazione futura: WebSockets o polling.

3. **File Uploads:** Audio e PDF uploads non ancora implementati nel NetworkService.

## Performance

### Ottimizzazioni
- Uso di `LazyVStack` per liste lunghe
- `@StateObject` per evitare ricreazioni
- Caricamento lazy dei dati
- Caching locale con UserDefaults (da migliorare)

### Future Optimizations
- Implementare paginazione per liste lunghe
- Cache immagini se aggiunte
- Background refresh per dati
- Prefetch dei dati

## Sicurezza

### Attuale
- Password oscurate nei field
- Sessione persistente con UserDefaults

### Da Implementare
- Keychain per credenziali sensibili
- Cifratura end-to-end per dati
- Token-based authentication
- Certificate pinning per API
- Biometric authentication (Face ID / Touch ID)

## Accessibilità

L'app utilizza elementi SwiftUI nativi che hanno accessibilità integrata:
- Labels semantici
- Contrast adeguato
- Dynamic Type support

### Future Improvements
- VoiceOver labels custom
- Accessibility identifiers per testing
- Supporto reduced motion

## Localizzazione

Attualmente l'app è in Italiano.

Per aggiungere altre lingue:
1. Xcode → Project → Info → Localizations → +
2. Usa `NSLocalizedString` per testi
3. Crea file `Localizable.strings`

## CI/CD (Future)

### GitHub Actions Workflow Example
```yaml
name: iOS CI

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build
        run: xcodebuild -scheme KilwinningApp -destination 'platform=iOS Simulator,name=iPhone 15'
      - name: Test
        run: xcodebuild test -scheme KilwinningApp
```

## Deployment

### App Store Checklist
- [ ] App Icons (tutti i formati)
- [ ] Launch Screen
- [ ] Privacy Policy
- [ ] Terms of Service
- [ ] Screenshots per tutte le dimensioni
- [ ] App description
- [ ] Keywords
- [ ] Categories
- [ ] Age rating
- [ ] Test su dispositivi reali
- [ ] Performance testing
- [ ] Security audit

## Metriche e Analytics (Future)

Considerare integrazione:
- Firebase Analytics
- Apple Analytics
- Crash reporting (Crashlytics)
- User behavior tracking

## Versioning

Seguire Semantic Versioning:
- MAJOR.MINOR.PATCH
- Es: 1.0.0 → 1.1.0 → 2.0.0

## Note per Sviluppatori

### Best Practices
1. Usa `@MainActor` per services che aggiornano UI
2. Evita retain cycles con `[weak self]`
3. Usa `async/await` invece di callbacks
4. Mantieni views piccole e componibili
5. Separa logica business dalle views

### Code Style
- SwiftLint per consistency (da aggiungere)
- CamelCase per proprietà e metodi
- Commenti in Italiano per dominio specifico
- Documenta funzioni pubbliche

### Git Workflow
- Branch per feature: `feature/nome-feature`
- Branch per bugfix: `bugfix/nome-bug`
- Pull request con review
- Squash commits prima del merge

## Risorse Utili

### Documentazione
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Tools
- Xcode
- SF Symbols (icone)
- Instruments (profiling)
- Accessibility Inspector

### Community
- Swift Forums
- Stack Overflow
- GitHub Discussions
