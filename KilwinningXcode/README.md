# Kilwinning App - Progetto Xcode

## 🎉 Progetto Pronto per Xcode!

Questo è il progetto Xcode completo e funzionante per l'app Kilwinning. È stato convertito dal Swift Package originale in un vero progetto Xcode per iOS.

## 📋 Cosa è Stato Fatto

✅ **Struttura Completa del Progetto:**
- File `.xcodeproj` creato con 44 file Swift
- `Info.plist` configurato con tutte le permissions necessarie
- `Assets.xcassets` con AppIcon e AccentColor
- `Config.plist` incluso nelle risorse del bundle
- Scheme Xcode configurato e pronto

✅ **Configurazione:**
- **Bundle ID**: `com.kilwinning.app`
- **Target**: iOS 17.0+
- **Piattaforme**: iPhone e iPad
- **Build Configurations**: Debug e Release

✅ **File Organizzati per Categoria:**
- 📁 **Core**: AppConstants, AppEnvironment
- 📁 **Models**: Brother, Tornata, Presenza, Tavola, Libro, Chat, Audio, etc.
- 📁 **Services**: Authentication, Data, Network, Chat, Audio, Library, Notifications
- 📁 **Repositories**: Mock e Remote implementations
- 📁 **Views**: Dashboard, Login, Tornate, Presenze, Biblioteca, Chat, etc.
- 📁 **Utilities**: AppTheme, CommonViews

## 🚀 Come Aprire e Buildare in Xcode

### Passo 1: Apri il Progetto
```bash
cd /path/to/Kilwinning/KilwinningXcode
open Kilwinning.xcodeproj
```

**Oppure** da Xcode:
1. Apri Xcode
2. File → Open...
3. Naviga fino a `Kilwinning/KilwinningXcode/`
4. Seleziona **Kilwinning.xcodeproj**
5. Clicca "Open"

### Passo 2: Seleziona il Simulatore
1. In alto a sinistra in Xcode, clicca sul menu device
2. Seleziona un simulatore iOS (es. "iPhone 15 Pro")
3. Oppure seleziona "Any iOS Device (arm64)"

### Passo 3: Build e Run
1. Premi **⌘ + B** per buildare
2. Premi **⌘ + R** per buildare ed eseguire
3. Aspetta che il simulatore si avvii

### Passo 4: Testing su Dispositivo Reale
Per testare su iPhone/iPad reale:
1. Collega il dispositivo via USB
2. In Xcode, vai su "Signing & Capabilities"
3. Seleziona il tuo **Team** (serve un Apple Developer Account)
4. Xcode configurerà automaticamente il provisioning profile
5. Seleziona il tuo dispositivo nel menu device
6. Premi **⌘ + R**

## 🔧 Configurazione Code Signing

### Per Testing Personale (Gratis)
1. In Xcode, seleziona il target "Kilwinning"
2. Vai su "Signing & Capabilities"
3. Abilita "Automatically manage signing"
4. Seleziona il tuo Personal Team (il tuo Apple ID)

### Per Distribuzione (Richiede Apple Developer Program)
1. Cambia Bundle ID se necessario (deve essere univoco)
2. Seleziona il team del Developer Program
3. Xcode scaricherà i certificati e profiles necessari

## 📱 Come Vedere l'App Durante lo Sviluppo

### Simulatore iOS
- **Pro**: Veloce, non serve dispositivo fisico
- **Contro**: Alcune features native non funzionano (notifiche push, camera, etc.)
- **Shortcut utili**:
  - **⌘ + ←/→**: Ruota dispositivo
  - **⌘ + Shift + H**: Home button
  - **⌘ + L**: Lock screen

### Preview in Xcode (Live Preview)
Per ogni View SwiftUI puoi usare il Canvas:
1. Apri un file View (es. `DashboardView.swift`)
2. Clicca "Editor" → "Canvas" (o premi **⌥ + ⌘ + Return**)
3. Clicca "Resume" nel canvas
4. Vedrai l'anteprima live della view

**Nota**: Se il preview ha un `#Preview`, vedrai automaticamente l'anteprima.

### Hot Reload
Xcode supporta SwiftUI live preview:
- Modifica il codice
- Il canvas si aggiorna automaticamente
- Non serve rebuildar l'intera app!

## 🎨 Come Modificare l'Interfaccia

### Modificare Colori
1. Apri `Utilities/AppTheme.swift`
2. Modifica i colori nella struct `AppTheme`
3. Oppure apri `Assets.xcassets/AccentColor.colorset`
4. Clicca sul colore e usa il color picker

### Modificare Layout
1. Apri la View che vuoi modificare (es. `Views/DashboardView.swift`)
2. Modifica il codice SwiftUI
3. Usa il Canvas per vedere le modifiche in real-time
4. Oppure rebuilda e testa nel simulatore

### Aggiungere Nuove View
1. File → New → File...
2. Seleziona "Swift File"
3. Crea la tua View SwiftUI:
```swift
import SwiftUI

struct MyNewView: View {
    var body: some View {
        Text("Hello Kilwinning!")
    }
}

#Preview {
    MyNewView()
}
```

## 🐛 Risoluzione Problemi Comuni

### Errore: "Failed to build module"
**Soluzione**:
1. Product → Clean Build Folder (⌘ + Shift + K)
2. Chiudi e riapri Xcode
3. Rebuilda (⌘ + B)

### Errore: "No such module 'SwiftUI'"
**Soluzione**:
- Verifica che il deployment target sia iOS 17.0+
- Vai su Project Settings → General → Deployment Target

### App non si avvia nel simulatore
**Soluzione**:
1. Simulator → Device → Erase All Content and Settings
2. Rebuilda l'app
3. Se persiste, riavvia il simulatore

### Errori di Code Signing
**Soluzione**:
1. Vai su Signing & Capabilities
2. Disabilita e riabilita "Automatically manage signing"
3. Oppure cambia il Bundle ID in uno univoco

## 📦 Struttura File

```
Kilwinning.xcodeproj/
├── project.pbxproj          # Configurazione progetto
└── xcshareddata/
    └── xcschemes/
        └── Kilwinning.xcscheme   # Build scheme

Kilwinning/                  # Source code
├── KilwinningApp.swift     # Entry point @main
├── Info.plist              # App configuration
├── Config.plist            # API endpoints
├── Assets.xcassets/        # Images, colors, icons
├── Core/                   # App constants & environment
├── Models/                 # Data models
├── Services/               # Business logic
├── Repositories/           # Data access layer
├── Views/                  # SwiftUI views
└── Utilities/              # Helpers & theme
```

## 🔄 Prossimi Passi

### Ora Puoi:
1. ✅ **Buildare** l'app in Xcode
2. ✅ **Eseguire** nel simulatore iOS
3. ✅ **Testare** su dispositivo reale (iPhone/iPad)
4. ✅ **Modificare** l'interfaccia e vedere i cambiamenti
5. ✅ **Debuggare** con breakpoints
6. ✅ **Vedere logs** nella console di Xcode

### Test Suggeriti:
1. **Login**: Usa `demo@kilwinning.it` / `demo123`
2. **Naviga** tra le varie sezioni (Tornate, Presenze, Biblioteca)
3. **Verifica** che le view si carichino correttamente
4. **Controlla** la console per eventuali warning/errori

## ⚙️ Configurazione Avanzata

### Cambiare Bundle ID
1. Seleziona il progetto in Xcode
2. Vai su target "Kilwinning"
3. General → Identity → Bundle Identifier
4. Cambia in `com.tuodominio.kilwinning`

### Aggiungere Capabilities
1. Target → Signing & Capabilities
2. Clicca "+ Capability"
3. Seleziona (es. Push Notifications, iCloud, etc.)

### Configurare Backend API
1. Apri `Kilwinning/Config.plist`
2. Modifica `api_base_url` con il tuo server
3. Rebuilda l'app

## 📚 Risorse Utili

- **SwiftUI Documentation**: https://developer.apple.com/documentation/swiftui/
- **Xcode Help**: Help → Xcode Help nel menu
- **WWDC Videos**: https://developer.apple.com/videos/

## 🆘 Supporto

Se incontri problemi:
1. Controlla la console di Xcode per errori dettagliati
2. Usa Product → Clean Build Folder
3. Riavvia Xcode
4. Verifica che tutti i file siano inclusi nel target

---

**Versione**: 1.0
**Data**: Novembre 2025
**Piattaforme**: iOS 17.0+
**Swift Version**: 5.9
