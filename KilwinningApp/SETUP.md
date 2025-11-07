# Setup Guide - Kilwinning App

## Requisiti di Sistema

### Per Sviluppo e Build
- **macOS**: Sonoma 14.0 o superiore
- **Xcode**: 15.0 o superiore  
- **Swift**: 5.9 o superiore

### Target dell'App
- **iOS**: 17.0 o superiore
- **macOS**: 14.0 (Sonoma) o superiore

## Installazione e Setup

### 1. Clone del Repository

```bash
git clone https://github.com/GenzoWakabayashi22/Kilwinning.git
cd Kilwinning/KilwinningApp
```

### 2. Apertura del Progetto in Xcode

Ci sono due modi per aprire il progetto:

**Metodo 1 - Apri direttamente il Package (consigliato):**
```bash
open Package.swift
```

**Metodo 2 - Genera un progetto Xcode:**
```bash
swift package generate-xcodeproj
open KilwinningApp.xcodeproj
```

### 3. Configurazione del Progetto in Xcode

#### a. Seleziona il Target
- In Xcode, seleziona il target appropriato dalla barra superiore:
  - `KilwinningApp (iOS)` per build iOS
  - `KilwinningApp (macOS)` per build macOS

#### b. Configurazione Signing & Capabilities
1. Seleziona il progetto nel navigatore
2. Vai su "Signing & Capabilities"
3. Seleziona il tuo Team di sviluppo
4. Cambia il Bundle Identifier (es. `com.tuoteam.kilwinning`)

#### c. Schema Configuration
Per eseguire l'app:
- iOS: Scegli un simulatore iOS 17+ o dispositivo fisico
- macOS: Scegli "My Mac"

### 4. Build ed Esecuzione

```bash
# Da linea di comando (macOS)
swift build

# In Xcode
# Premi Cmd+B per build
# Premi Cmd+R per run
```

### 5. Esecuzione Test

```bash
# Da linea di comando
swift test

# In Xcode
# Premi Cmd+U
```

## Struttura per Xcode Project

Se preferisci lavorare con un progetto Xcode tradizionale invece del Package:

### Creazione Progetto Xcode da Zero

1. Apri Xcode
2. File → New → Project
3. Scegli:
   - iOS → App (per iOS)
   - macOS → App (per macOS)  
   - Oppure "Multiplatform → App" per entrambi
4. Configura:
   - Product Name: `KilwinningApp`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Use Core Data: No
   - Include Tests: Yes

5. Copia i file sorgente nella struttura Xcode:
   ```
   KilwinningApp/
   ├── Models/
   ├── Views/
   ├── Services/
   ├── Utilities/
   └── KilwinningApp.swift
   ```

## Build per Distribuzione

### iOS App Store

1. Archive l'app:
   - Product → Archive

2. Distribuzione:
   - Window → Organizer → Distribute App
   - App Store Connect

### macOS App Store

1. Archive l'app:
   - Product → Archive

2. Distribuzione:
   - Window → Organizer → Distribute App
   - App Store Connect

### TestFlight (Beta Testing)

1. Dopo l'archive, carica su TestFlight tramite Organizer
2. Invita beta testers tramite App Store Connect

## Configurazione Backend

### Opzione 1: CloudKit (Consigliato per Apple Ecosystem)

1. In Xcode, aggiungi CloudKit capability:
   - Target → Signing & Capabilities → + Capability → CloudKit

2. Crea un Container CloudKit su developer.apple.com

3. Aggiorna `AuthenticationService.swift` e `DataService.swift` per usare CloudKit

### Opzione 2: Firebase

1. Aggiungi Firebase al progetto:
   ```bash
   # Nel Package.swift, aggiungi:
   .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
   ```

2. Scarica `GoogleService-Info.plist` da Firebase Console

3. Aggiungi al progetto Xcode

4. Aggiorna i servizi per usare Firebase

### Opzione 3: Custom Backend REST API

1. Configura l'URL base del backend in un file di configurazione

2. Implementa le chiamate API in `AuthenticationService` e `DataService`

## Login Demo

Per testare l'app senza backend:

- **Email**: demo@kilwinning.it
- **Password**: demo123

## Risoluzione Problemi

### "No such module 'SwiftUI'"
- Assicurati di usare macOS (SwiftUI non è disponibile su Linux)
- Verifica di avere Xcode installato
- Apri il progetto in Xcode, non da terminale Linux

### "Failed to build"
- Pulisci la build: Product → Clean Build Folder (Cmd+Shift+K)
- Elimina Derived Data: Xcode → Preferences → Locations → Derived Data → Delete

### Simulatore non disponibile
- Apri Xcode → Preferences → Components
- Scarica i simulatori iOS necessari

### Signing Issues
- Vai su Signing & Capabilities
- Seleziona il tuo team di sviluppo
- Cambia il Bundle Identifier con uno unico

## Dipendenze Esterne

Il progetto attualmente non ha dipendenze esterne. Se vuoi aggiungere package:

```swift
// In Package.swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0")
]
```

## Prossimi Passi

1. ✅ Build del progetto su Xcode
2. ✅ Test su simulatore iOS
3. ✅ Test su macOS
4. ⏳ Configurazione CloudKit/Firebase
5. ⏳ Implementazione autenticazione backend
6. ⏳ Test su dispositivi fisici
7. ⏳ Submit ad App Store

## Supporto

Per domande o problemi:
- Controlla la documentazione Apple su developer.apple.com
- Rivedi il README.md principale
- Consulta la documentazione SwiftUI

---

**Nota Importante**: Questa app è progettata per macOS/iOS e richiede Xcode per build e sviluppo. Non può essere compilata in ambienti Linux o Windows.
