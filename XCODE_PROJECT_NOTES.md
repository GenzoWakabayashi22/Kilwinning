# Note Tecniche - Conversione a Progetto Xcode

## 🔧 Problemi Risolti

### 1. Configurazione Errata del Package ✅ RISOLTO
**Problema Originale**:
- Il Package.swift era configurato come `.executable` invece di un'app iOS
- Impossibile buildare come app GUI in Xcode

**Soluzione Implementata**:
- Creato nuovo progetto Xcode completo in `KilwinningXcode/`
- Copiato tutto il codice Swift dal package originale
- Creato `project.pbxproj` con riferimenti a tutti i 44 file Swift
- Configurato scheme Xcode per build e run

### 2. Mancanza di Assets e Risorse ✅ RISOLTO
**Problema**: Nessun Assets.xcassets o plist files

**Soluzione**:
- Creato `Assets.xcassets` con AppIcon e AccentColor
- Creato `Info.plist` con tutte le configurazioni necessarie
- Incluso `Config.plist` nelle risorse del bundle
- Configurate permissions per UserNotifications

### 3. Bundle.main Access ✅ RISOLTO
**Problema**: In un executable Swift Package, `Bundle.main` non accede alle risorse

**Soluzione**:
- Config.plist ora è incluso nelle "Copy Bundle Resources" del target
- `Bundle.main.path(forResource: "Config", ofType: "plist")` funzionerà correttamente

## ⚠️ Problemi Noti da Risolvere

### 1. Mismatch ID Types (UUID vs Int)
**Problema**:
- I modelli Swift usano `UUID` per gli ID (Brother, Tornata, etc.)
- Il backend API usa `Int` per gli ID
- Questo causa problemi in ChatService e AudioService

**Esempio Critico** (ChatService.swift:248):
```swift
let messaggio = MessaggioChat(
    id: dto.id,
    idChat: dto.idChat,
    idMittente: UUID(), // ⚠️ Genera UUID casuale!
    testo: dto.testo,
    timestamp: dto.timestamp,
    stato: .inviato
)
```

**Impatto**:
- I messaggi chat avranno ID mittente errati
- Impossibile tracciare correttamente chi ha inviato i messaggi
- Relazioni Brother ↔ Messaggio rotte

**Soluzioni Possibili**:
1. **Opzione A**: Mantenere mapping UUID ↔ Int
   - Pro: Non serve modificare i modelli
   - Contro: Complesso, serve persistenza del mapping

2. **Opzione B**: Cambiare tutti gli ID a Int
   - Pro: Allineamento con backend
   - Contro: Refactoring massiccio

3. **Opzione C** (Consigliata): Usare String per tutti gli ID
   - Pro: Flessibile, supporta sia UUID che Int
   - Contro: Leggero overhead di conversione

### 2. MainActor Inconsistencies
**Problema**:
- `ChatService` e `AudioService` NON sono `@MainActor`
- Ma usano `@Published` properties (che richiedono main thread)

**Codice Problematico**:
```swift
class ChatService: ObservableObject { // ⚠️ Dovrebbe essere @MainActor
    @Published var chatRooms: [ChatRoom] = []
    @Published var messaggi: [MessaggioChat] = []

    init(networkService: NetworkService? = nil) {
        MainActor.assumeIsolated { // ⚠️ Workaround pericoloso
            self.networkService = networkService ?? NetworkService()
        }
    }
}
```

**Soluzione**:
```swift
@MainActor
class ChatService: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var messaggi: [MessaggioChat] = []

    init(networkService: NetworkService? = nil) {
        self.networkService = networkService ?? NetworkService()
    }
}
```

### 3. Backend Integration Incompleta
**Status**: Solo mock data è implementato

**Repositories Mancanti**:
- ❌ `RemotePresenzeRepository` (esiste solo Mock)
- ❌ `RemoteTavoleRepository` (non implementato)
- ❌ `RemoteBibliotecaRepository` (non implementato)
- ❌ `RemoteFratelliRepository` (non implementato)
- ✅ `RemoteTornateRepository` (parziale)

**Endpoint API Non Implementati**:
- POST per creare nuove tornate
- DELETE per rimuovere tornate
- POST per confermare presenze
- POST per caricare tavole
- DELETE per gestire prestiti

### 4. Error Handling Non Consistente
**Problema**: Alcuni metodi async non propagano errori correttamente

**Esempio**:
```swift
func loadData() async {
    do {
        let data = try await fetchData()
        // ...
    } catch {
        print("Error: \(error)") // ⚠️ Solo print, non espone all'UI
    }
}
```

**Soluzione Migliore**:
```swift
@Published var errorMessage: String?

func loadData() async {
    do {
        let data = try await fetchData()
        // ...
        errorMessage = nil
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

## 📊 Metriche del Codice

### Statistiche Generali
- **File Swift**: 44
- **Modelli**: 10 (Brother, Tornata, Presence, Tavola, Libro, Prestito, ChatRoom, MessaggioChat, AudioDiscussione, Notification)
- **Services**: 7 (Auth, Data, Network, Chat, Audio, Library, Notifications)
- **Views**: 18
- **Repositories**: 3 implementati, 4 mancanti

### Lines of Code (Approssimato)
- Models: ~800 LOC
- Services: ~1500 LOC
- Views: ~2000 LOC
- Repositories: ~400 LOC
- **Totale**: ~5000 LOC

## 🎯 Priorità per Sviluppi Futuri

### Alta Priorità (Blocca Funzionalità)
1. **Risolvere UUID/Int mismatch** - Impedisce chat e audio di funzionare
2. **Aggiungere @MainActor a ChatService e AudioService** - Fix thread safety
3. **Implementare RemotePresenzeRepository** - Necessario per presenze reali

### Media Priorità (Migliora UX)
4. **Completare error handling** - Mostrare errori all'utente
5. **Implementare repository mancanti** - Per funzionalità complete
6. **Aggiungere loading states** - Feedback durante network calls

### Bassa Priorità (Nice to Have)
7. **Aggiungere test unitari** - Attualmente solo 4 test files
8. **Implementare caching** - Per dati frequentemente acceduti
9. **Aggiungere analytics** - Per tracciare uso app

## 🔐 Note di Sicurezza

### Gestione Credenziali
**Attuale**: Credenziali hardcoded in AuthenticationService
```swift
private let demoEmail = "demo@kilwinning.it"
private let demoPassword = "demo123"
```

**Da Fare**:
- [ ] Implementare autenticazione vera con backend
- [ ] Usare Keychain per salvare token
- [ ] Implementare refresh token
- [ ] Aggiungere 2FA (opzionale)

### API Security
**Attuale**: Nessuna autenticazione nelle chiamate API

**Da Fare**:
- [ ] Aggiungere Authorization header con bearer token
- [ ] Implementare SSL pinning per produzione
- [ ] Validare certificati server

## 📝 Convenzioni Codice

### Naming
- **Models**: PascalCase (Brother, Tornata)
- **Properties**: camelCase (firstName, lastName)
- **Constants**: camelCase (apiBaseURL)
- **Enums**: PascalCase (MasonicDegree, TornataType)

### Architecture Pattern
- **MVVM**: Models + ViewModels (Services) + Views
- **Repository Pattern**: Data access layer separato
- **Dependency Injection**: Via AppEnvironment

### SwiftUI Best Practices
- ✅ Usa `@StateObject` per object ownership
- ✅ Usa `@EnvironmentObject` per shared state
- ✅ Usa `@Published` per observable properties
- ✅ Async/await per network calls
- ⚠️ Evita `@State` per oggetti complessi (usa `@StateObject`)

## 🚀 Deployment Notes

### Per TestFlight
1. Cambia Bundle ID in uno univoco
2. Incrementa `CFBundleVersion` in Info.plist
3. Archive build in Xcode (Product → Archive)
4. Upload to App Store Connect
5. Aggiungi tester in TestFlight

### Per App Store
1. Aggiungi screenshots (richiesti)
2. Scrivi description e keywords
3. Configura privacy manifest se richiesto
4. Submit for review

### Requisiti Apple
- [ ] Privacy Policy URL (se raccogli dati utente)
- [ ] Terms of Service
- [ ] Support URL
- [ ] App Icon (1024x1024)
- [ ] Screenshots per tutte le dimensioni device

## 🔄 Workflow di Sviluppo Consigliato

### 1. Branching Strategy
```
main                    # Produzione
  ├── develop          # Sviluppo
  │   ├── feature/*   # Nuove features
  │   ├── bugfix/*    # Bug fixes
  │   └── hotfix/*    # Hotfixes urgenti
```

### 2. Development Cycle
1. Crea feature branch da develop
2. Sviluppa e testa localmente
3. Apri PR verso develop
4. Review e merge
5. Test su develop
6. Merge su main per release

### 3. Testing Checklist
- [ ] Compile senza errori
- [ ] Nessun warning critico
- [ ] Test su iPhone e iPad simulators
- [ ] Test su device reale
- [ ] Test login/logout
- [ ] Test tutte le view principali
- [ ] Verifica network calls (con backend mock o reale)

## 📖 Documentazione Esistente

Documenti già presenti nel repository:
- `ANALISI_PROGETTO.md` - Analisi dettagliata originale
- `COMPLETAMENTO_ANALISI.md` - Analisi completamento features
- `IMPLEMENTATION_SUMMARY.md` - Summary implementazione
- `PIANO_IMPLEMENTAZIONE.md` - Piano originale
- `PROJECT_SUMMARY.md` - Summary progetto
- `DOCUMENTATION.md` - Documentazione generale
- `GUIDA_UTENTE.md` - Guida per utenti finali
- `QUICK_START.md` - Quick start guide

**Nuovo**:
- `KilwinningXcode/README.md` - Guida uso progetto Xcode
- `XCODE_PROJECT_NOTES.md` - Questo file

## 🎓 Risorse di Apprendimento

### SwiftUI
- Apple SwiftUI Tutorials: https://developer.apple.com/tutorials/swiftui
- WWDC SwiftUI Videos: https://developer.apple.com/videos/swiftui

### Xcode
- Xcode Documentation: https://developer.apple.com/xcode/
- Debugging in Xcode: https://developer.apple.com/debugging/

### Swift Concurrency
- Swift async/await: https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html
- MainActor: https://developer.apple.com/documentation/swift/mainactor

---

**Autore**: Claude (Anthropic)
**Data Creazione**: 8 Novembre 2025
**Versione Progetto**: 1.0
