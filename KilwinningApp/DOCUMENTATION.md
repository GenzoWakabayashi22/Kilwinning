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

### DataService
Gestisce tutti i dati dell'app:

**Funzionalità:**
- Gestione Tornate (CRUD)
- Gestione Presenze
- Calcolo statistiche
- Gestione Tavole

**Stato:**
- `@Published var tornate: [Tornata]`
- `@Published var presences: [Presence]`
- `@Published var tavole: [Tavola]`
- `@Published var brothers: [Brother]`

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

### Placeholder per API Calls

I services contengono placeholder per chiamate backend:

```swift
// TODO: Implementare chiamata reale a backend
try await Task.sleep(nanoseconds: 1_000_000_000)
```

### CloudKit Integration (Futuro)

```swift
import CloudKit

let container = CKContainer.default()
let database = container.publicCloudDatabase

// Fetch, Save, Update, Delete operations
```

### Firebase Integration (Alternativa)

```swift
import FirebaseAuth
import FirebaseFirestore

// Auth
Auth.auth().signIn(withEmail: email, password: password)

// Firestore
let db = Firestore.firestore()
db.collection("tornate").getDocuments()
```

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
