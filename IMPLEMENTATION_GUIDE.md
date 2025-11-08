# 🎯 Guida Implementazione App iOS/macOS Kilwinning

## 📋 Panoramica

Questa guida documenta l'implementazione delle nuove funzionalità richieste per l'app nativa iOS/macOS della Loggia Kilwinning, in conformità con il backend Node.js.

## ✅ Funzionalità Implementate

### 1. **Keychain Helper** (`Utilities/KeychainHelper.swift`)
- ✅ Gestione sicura del token di autenticazione
- ✅ Storage del user ID
- ✅ Gestione timeout sessione (8 ore)
- ✅ Metodi per salvare/recuperare/eliminare dati sensibili

**Metodi principali:**
```swift
KeychainHelper.shared.saveToken(_ token: String)
KeychainHelper.shared.getToken() -> String?
KeychainHelper.shared.isSessionExpired() -> Bool
KeychainHelper.shared.clearAll()
```

### 2. **Modelli Dati Aggiornati**

#### Brother Model (`Models/Brother.swift`)
- ✅ Aggiunto campo `id: Int` (compatibilità backend)
- ✅ Aggiunto campo `nome: String`
- ✅ Aggiunto campo `grado: String`
- ✅ Aggiunto campo `caricaFissa: String?`
- ✅ **Date massoniche**: `dataIniziazione`, `dataPassaggio`, `dataElevazione`
- ✅ CodingKeys per mappatura API (snake_case ↔ camelCase)

#### Tornata Model (`Models/Tornata.swift`)
- ✅ Aggiunto campo `id: Int`
- ✅ Aggiunto campo `discussione: String`
- ✅ Aggiunto campo `stato: String` (programmata/completata/annullata)
- ✅ Aggiunto enum `TornataStatus`
- ✅ Supporto tipo "straordinaria"

#### Presence Model (`Models/Presence.swift`)
- ✅ Aggiunto campo `fratelloId: Int`
- ✅ Aggiunto campo `presente: Bool`
- ✅ CodingKeys per compatibilità backend

#### PresenceStatistics (`Models/Presence.swift`)
- ✅ Aggiunto campo `presenzeConsecutive: Int` ⭐
- ✅ Aggiunto campo `totaliTornate: Int`
- ✅ Aggiunto campo `presenzeCount: Int`
- ✅ Aggiunto campo `percentuale: Int`

### 3. **TornateAPIService** (`Services/TornateAPIService.swift`)
Service completo per integrazione con backend Node.js su `https://tornate.loggiakilwinning.com/api`

**Endpoint implementati:**

#### Auth
- `POST /fratelli/login` → Login con nome
- `GET /fratelli/me` → Verifica sessione
- `POST /fratelli/logout` → Logout

#### Presenze
- `GET /presenze/fratello/:id?anno=2025` → Presenze filtrate
- `GET /presenze/fratello/:id/statistiche?anno=tutti` → Statistiche
- `GET /presenze/riepilogo-fratelli?anno=2025` → Riepilogo tutti fratelli
- `POST /presenze` → Aggiorna presenza

#### Tornate
- `GET /tornate?anno=2025&stato=programmata` → Tornate filtrate
- `POST /admin/tornate` → Crea tornata (admin)
- `PUT /admin/tornate/:id` → Modifica tornata (admin)
- `DELETE /admin/tornate/:id` → Elimina tornata (admin)

#### Fratelli
- `GET /fratelli` → Lista fratelli
- `PUT /fratelli/:id` → Aggiorna gradi

### 4. **PresenceCalculator** (`Utilities/PresenceCalculator.swift`)
Utility per calcoli statistiche e logiche business.

**Funzioni critiche:**

#### 🔥 Calcolo Presenze Consecutive
```swift
static func calculateConsecutive(presences: [Presence], tornate: [Tornata]) -> Int
```
- Ordina tornate per data (più recente prima)
- Conta presenze consecutive partendo dalla più recente
- Si ferma alla prima assenza

#### 📅 Filtro Data Iniziazione
```swift
static func filterTornateByInitiation(tornate: [Tornata], dataIniziazione: Date?) -> [Tornata]
```
- **IMPORTANTE**: Filtra tornate >= dataIniziazione
- Garantisce che solo tornate valide siano contate

#### Altre Utility
- `isAdmin(nome: String)` → Verifica se utente è admin
- `getDegreeIcon(grado: String)` → Emoji per grado (🔶🔷🔹)
- `getPercentageColor(percentuale: Int)` → Colore per percentuale
- `filterPresencesByYear()` → Filtra per anno

### 5. **Componenti UI Riutilizzabili** (`Views/Components/StatisticsComponents.swift`)

#### StatItem
Card per statistiche con icona, valore e label.
```swift
StatItem(icon: "checkmark.circle.fill", value: "24", label: "Presenze", color: .green)
```

#### TornataCard
Card per visualizzare tornata con opzioni admin.
```swift
TornataCard(tornata: tornata, showActions: true, onEdit: {}, onDelete: {})
```

#### ProgressBar
Barra di progresso con colori dinamici.
```swift
ProgressBar(value: 85) // 0-100
```
- Verde: 90-100%
- Arancione: 70-89%
- Rosso: <70%

#### ConsecutiveBadge
Badge 🔥 per presenze consecutive.
```swift
ConsecutiveBadge(count: 12)
```

#### DegreeBadge
Badge con icona grado.
```swift
DegreeBadge(grado: "Maestro") // 🔶 Maestro
```

#### StatisticsCard
Card completa statistiche con consecutive.

### 6. **Viste Principali**

#### EnhancedLoginView (`Views/EnhancedLoginView.swift`)
- ✅ Picker con lista fratelli dal backend
- ✅ Icone grado (🔶 Maestri, 🔷 Compagni, 🔹 Apprendisti)
- ✅ Ordinamento per grado
- ✅ Design con gradiente

#### EnhancedDashboardView (`Views/EnhancedDashboardView.swift`)
- ✅ Header con nome, grado e badge ADMIN
- ✅ StatisticsCard con presenze consecutive 🔥
- ✅ Prossime 3 tornate
- ✅ Bottone "Conferma Presenza"
- ✅ Quick actions grid

#### PresenzeEnhancedView (`Views/PresenzeEnhancedView.swift`)
- ✅ Picker anno (2020-2025 + "Tutti")
- ✅ Header statistiche con consecutive
- ✅ Lista tornate con toggle presenza
- ✅ Filtro automatico per dataIniziazione
- ✅ Pull to refresh

#### RiepilogoFratelliView (`Views/RiepilogoFratelliView.swift`)
- ✅ Lista tutti fratelli
- ✅ Progress bar per ogni fratello
- ✅ Percentuale presenze
- ✅ Badge grado
- ✅ Contatore "X/Y"

#### TornateManagementView (`Views/TornateManagementView.swift`)
- ✅ Lista tornate con azioni admin
- ✅ Bottone "+" per creare
- ✅ Sheet creazione tornata
- ✅ Sheet modifica tornata
- ✅ Alert conferma eliminazione
- ✅ Filtro per anno

### 7. **EnhancedAuthenticationService** (`Services/EnhancedAuthenticationService.swift`)
- ✅ Integrazione con TornateAPIService
- ✅ Uso di Keychain invece di UserDefaults
- ✅ Verifica sessione scaduta (8 ore)
- ✅ Check automatico sessione esistente
- ✅ Metodo `isAdmin` basato su nome

## 🔧 Come Integrare nell'App Esistente

### Opzione 1: Sostituzione Graduale

1. **Aggiornare KilwinningApp.swift**:
```swift
@StateObject private var enhancedAuthService = EnhancedAuthenticationService()

var body: some Scene {
    WindowGroup {
        Group {
            if enhancedAuthService.isAuthenticated {
                EnhancedDashboardView()
            } else {
                EnhancedLoginView()
            }
        }
        .environmentObject(enhancedAuthService)
    }
}
```

2. **Aggiornare Info.plist** per Keychain:
```xml
<key>UIApplicationSupportsIndirectInputEvents</key>
<true/>
```

3. **Aggiornare AppConstants.swift** con nuovo URL:
```swift
static let baseURL = "https://tornate.loggiakilwinning.com/api"
```

### Opzione 2: Modalità Parallela (Consigliato)

Mantenere entrambi i sistemi e switchare via flag:

```swift
enum AppMode {
    case legacy // Sistema PHP
    case enhanced // Sistema Node.js
}

@AppStorage("appMode") var appMode: AppMode = .enhanced

var body: some Scene {
    WindowGroup {
        if appMode == .enhanced {
            EnhancedContentView()
        } else {
            ContentView() // Legacy
        }
    }
}
```

## ✅ Validazioni Critiche Implementate

1. ✅ **Filtro Data Iniziazione**: Tutte le query presenze filtrano tornate >= dataIniziazione
2. ✅ **Consecutive dal Più Recente**: Algoritmo parte dalla tornata più recente
3. ✅ **Admin Check**: Nasconde CRUD se non admin (Paolo Giulio Gazzano, Emiliano Menicucci)
4. ✅ **Anno "Tutti" vs Specifico**: Gestione corretta del parametro anno
5. ✅ **Aggiornamento Stats**: Refresh dopo toggle presenza
6. ✅ **Keychain Security**: Token NON in UserDefaults
7. ✅ **Session Timeout**: 8 ore come richiesto

## 🧪 Testing

### Unit Tests da Implementare

```swift
// PresenceCalculatorTests.swift
func testCalculateConsecutive() {
    let presences = [/* mock data */]
    let tornate = [/* mock data */]
    let result = PresenceCalculator.calculateConsecutive(presences: presences, tornate: tornate)
    XCTAssertEqual(result, expectedValue)
}

func testFilterByInitiation() {
    let tornate = [/* mock data */]
    let dataIniziazione = Date()
    let result = PresenceCalculator.filterTornateByInitiation(tornate: tornate, dataIniziazione: dataIniziazione)
    // Verifica che tutte le tornate >= dataIniziazione
}
```

### UI Tests

```swift
func testLoginFlow() {
    app.launch()
    // Seleziona fratello da picker
    // Tap login
    // Verifica dashboard mostrata
}

func testTogglePresenza() {
    // Login
    // Vai a Presenze
    // Toggle presenza
    // Verifica statistiche aggiornate
}
```

### Mock API Service

Per preview e testing:
```swift
class MockTornateAPIService: TornateAPIService {
    override func getFratelli() async throws -> [Brother] {
        return [/* mock data */]
    }
}
```

## 📱 Features Mancanti (Da Implementare)

Le seguenti features erano nel prompt ma non ancora implementate:

1. **Offline Mode con CoreData**
   - Cache locale delle presenze/tornate
   - Sync automatico quando online

2. **Widget iOS**
   - Prossime 3 tornate
   - Aggiornamento automatico

3. **Face ID/Touch ID**
   - Login rapido dopo prima auth
   - Integrazione LocalAuthentication

4. **Export CSV** (Admin)
   - Riepilogo presenze esportabile

5. **Dark Mode**
   - Già supportato da SwiftUI di default, ma personalizzare colori

## 🚀 Prossimi Passi

1. ✅ Verificare build Xcode
2. ⬜ Testare integrazione con backend Node.js reale
3. ⬜ Implementare mock API per testing
4. ⬜ Aggiungere unit tests
5. ⬜ Implementare features mancanti (widget, Face ID, offline mode)
6. ⬜ Pubblicare su TestFlight per beta testing

## 📝 Note Importanti

- **Backend URL**: `https://tornate.loggiakilwinning.com/api`
- **Admin Users**: Paolo Giulio Gazzano, Emiliano Menicucci
- **Session Timeout**: 8 ore
- **Supported iOS**: 17.0+
- **Supported macOS**: 14.0+

## 🔗 File Principali Creati

```
Kilwinning/
├── Utilities/
│   ├── KeychainHelper.swift ⭐
│   └── PresenceCalculator.swift ⭐
├── Services/
│   ├── TornateAPIService.swift ⭐
│   └── EnhancedAuthenticationService.swift ⭐
├── Views/
│   ├── EnhancedLoginView.swift ⭐
│   ├── EnhancedDashboardView.swift ⭐
│   ├── PresenzeEnhancedView.swift ⭐
│   ├── RiepilogoFratelliView.swift ⭐
│   ├── TornateManagementView.swift ⭐
│   └── Components/
│       └── StatisticsComponents.swift ⭐
└── Models/
    ├── Brother.swift (updated)
    ├── Tornata.swift (updated)
    └── Presence.swift (updated)
```

## 📞 Supporto

Per domande o problemi sull'implementazione:
- Verificare che il backend Node.js sia online
- Controllare i log Xcode per errori di rete
- Testare gli endpoint API con Postman/curl
- Verificare i CodingKeys per compatibilità JSON

---

**Implementato con ❤️ per la Spettabile Loggia Kilwinning 🏛️**
