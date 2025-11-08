# Spettabile Loggia Kilwinning - App iOS e macOS

Benvenuto nel repository ufficiale dell'applicazione Kilwinning per la gestione delle tornate, presenze e tavole architettoniche della Loggia.

## 📱 Apertura del Progetto

Per aprire il progetto in Xcode:

1. **Doppio click su** `Kilwinning.xcodeproj` nella root del repository
2. Oppure da terminale:
   ```bash
   cd Kilwinning
   open Kilwinning.xcodeproj
   ```

## 📋 Requisiti di Sistema

- **Xcode**: 15.0 o superiore
- **iOS**: 17.0+ (supporto iPhone e iPad)
- **macOS**: 14.0+ (supporto nativo Mac)
- **Swift**: 5.9+

## 🚀 Come Buildare ed Eseguire

### Build dal Xcode

1. Apri `Kilwinning.xcodeproj`
2. Seleziona il target "Kilwinning"
3. Scegli il dispositivo (simulatore iOS, Mac, o dispositivo fisico)
4. Premi `Cmd + R` per buildare ed eseguire

### Build da Linea di Comando

```bash
# Build per iOS Simulator
xcodebuild -project Kilwinning.xcodeproj -scheme Kilwinning -sdk iphonesimulator

# Build per macOS
xcodebuild -project Kilwinning.xcodeproj -scheme Kilwinning -sdk macosx
```

## 📂 Struttura del Progetto

```
Kilwinning/
├── Kilwinning.xcodeproj/     # Progetto Xcode
├── Kilwinning/               # Codice sorgente
│   ├── KilwinningApp.swift  # Entry point dell'app
│   ├── Core/                # Costanti e configurazione
│   ├── Models/              # Modelli dati (Brother, Tornata, ecc.)
│   ├── Views/               # UI SwiftUI
│   ├── Services/            # Servizi (Auth, Network, Data)
│   ├── Repositories/        # Layer accesso dati
│   ├── Utilities/           # Utility e temi
│   ├── Info.plist          # Configurazione app
│   ├── Config.plist        # Configurazione API
│   └── Assets.xcassets     # Risorse grafiche
├── api/                     # Backend REST API PHP
├── backend/                 # Backend Node.js
└── README.md               # Questo file
```

## ✨ Caratteristiche Principali

- ✅ **Multi-piattaforma**: iOS 17+ e macOS 14+
- ✅ **Autenticazione**: Login sicuro con email/password
- ✅ **Dashboard Personale**: Statistiche e informazioni del fratello
- ✅ **Gestione Tornate**: Elenco, dettagli, conferma presenza
- ✅ **Statistiche Presenze**: Grafici e record personali
- ✅ **Biblioteca**: Catalogo libri e gestione prestiti
- ✅ **Tavole Architettoniche**: Gestione completa con PDF viewer
- ✅ **Chat**: Sistema messaggistica interno
- ✅ **Audio Discussioni**: Registrazione e playback discussioni
- ✅ **Notifiche**: Sistema notifiche in-app
- ✅ **Amministrazione**: Pannello per Ven.mo Maestro e Segretario
- ✅ **Design Istituzionale**: Tema azzurro massonico, bianco e oro

## 🔧 Configurazione

### API Backend

Il file `Kilwinning/Config.plist` contiene la configurazione dell'API backend:

```xml
<key>API_BASE_URL</key>
<string>https://loggiakilwinning.com/api/</string>
```

Modifica questo file per puntare al tuo server API.

### Bundle Identifier

Il Bundle ID del progetto è: `com.kilwinning.app`

Puoi modificarlo nelle impostazioni del target in Xcode se necessario.

## 🏗️ Architettura

L'app utilizza un'architettura **MVVM** (Model-View-ViewModel) con SwiftUI:

- **Models**: Strutture dati Codable per API
- **Views**: Componenti UI SwiftUI
- **Services**: Business logic e comunicazione API
- **Repositories**: Pattern repository per astrazione dati

## 🔐 Sicurezza

- Autenticazione sicura con gestione sessioni
- Controllo accessi basato su ruoli
- Connessioni HTTPS con il backend
- Protezione dati locali

## 🌐 Backend REST API

Il sistema si integra con un backend PHP/MySQL. Documentazione completa in `/api/README.md`.

Endpoint principali:
- `/api/tornate` - Gestione tornate
- `/api/presenze` - Registrazione presenze
- `/api/tavole` - Tavole architettoniche
- `/api/libri` - Biblioteca
- `/api/prestiti` - Gestione prestiti
- `/api/chat` - Messaggistica
- `/api/audio_discussioni` - Audio
- `/api/notifiche` - Notifiche

## 🧪 Testing

L'app include test unitari. Per eseguirli:

```bash
xcodebuild test -project Kilwinning.xcodeproj -scheme Kilwinning -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📄 Licenza

Copyright © 2025 Loggia Kilwinning. Tutti i diritti riservati.

## 📞 Supporto

Per supporto tecnico o domande:
- Apri un issue su GitHub
- Contatta il team di sviluppo

---

**Versione**: 1.0.0  
**Ultimo Aggiornamento**: Novembre 2025  

**Sviluppato con ❤️ per la Spettabile Loggia Kilwinning 🏛️**
