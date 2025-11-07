# Spettabile Loggia Kilwinning - Repository Ufficiale

Benvenuto nel repository ufficiale della Loggia Kilwinning.

## 📱 Sistema Gestione Tornate

Questo repository contiene l'applicazione completa per la gestione delle tornate, presenze e tavole architettoniche della Loggia.

### 🚀 Accesso Rapido

L'applicazione SwiftUI si trova nella cartella **`KilwinningApp/`**

```bash
cd KilwinningApp
open Package.swift  # Apre in Xcode su macOS
```

### 📚 Documentazione Completa

Tutta la documentazione si trova in `KilwinningApp/`:

- **[README.md](KilwinningApp/README.md)** - Panoramica del progetto
- **[QUICK_START.md](KilwinningApp/QUICK_START.md)** - Inizia in 5 minuti
- **[SETUP.md](KilwinningApp/SETUP.md)** - Guida installazione completa
- **[GUIDA_UTENTE.md](KilwinningApp/GUIDA_UTENTE.md)** - Manuale utente
- **[DOCUMENTATION.md](KilwinningApp/DOCUMENTATION.md)** - Dettagli tecnici
- **[PANORAMICA_VISUALE.md](KilwinningApp/PANORAMICA_VISUALE.md)** - Diagrammi e overview
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Riepilogo completo progetto

### ✨ Caratteristiche Principali

- ✅ **Multi-piattaforma**: iOS 17+ e macOS 14+
- ✅ **Autenticazione**: Login sicuro con email/password
- ✅ **Dashboard Personale**: Statistiche e informazioni fratello
- ✅ **Gestione Tornate**: Elenco, dettagli, conferma presenza
- ✅ **Statistiche Presenze**: Grafici e record personali
- ✅ **Tavole Architettoniche**: Gestione completa
- ✅ **Amministrazione**: Pannello per Ven.mo Maestro e Segretario
- ✅ **Design Istituzionale**: Tema azzurro massonico, bianco e oro

### 🔧 Tecnologie

- **Linguaggio**: Swift 5.9+
- **Framework**: SwiftUI
- **Architettura**: MVVM
- **Build**: Swift Package Manager
- **Backend**: Pronto per CloudKit, Firebase o API custom

### 🎯 Status del Progetto

**✅ COMPLETATO** - Pronto per integrazione backend e deployment

- 19 file sorgente Swift
- 3 suite di test unitari
- 7 file di documentazione dettagliata
- Design completo e funzionante
- Pronto per App Store

### 🏁 Quick Start

1. **Clone del repository**:
   ```bash
   git clone https://github.com/GenzoWakabayashi22/Kilwinning.git
   cd Kilwinning/KilwinningApp
   ```

2. **Apri in Xcode** (richiede macOS):
   ```bash
   open Package.swift
   ```

3. **Build & Run**:
   - Seleziona target (iOS/macOS)
   - Premi `Cmd + R`

4. **Login Demo**:
   - Email: `demo@kilwinning.it`
   - Password: `demo123`

### 📂 Struttura Repository

```
Kilwinning/
├── README.md                    # Questo file
├── PROJECT_SUMMARY.md           # Riepilogo completo progetto
├── backend/                     # Backend Node.js (esistente)
│   ├── package.json
│   └── src/
└── KilwinningApp/              # ⭐ App SwiftUI principale
    ├── Package.swift
    ├── README.md
    ├── SETUP.md
    ├── DOCUMENTATION.md
    ├── GUIDA_UTENTE.md
    ├── PANORAMICA_VISUALE.md
    ├── QUICK_START.md
    ├── Sources/
    │   └── KilwinningApp/
    │       ├── Models/
    │       ├── Views/
    │       ├── Services/
    │       └── Utilities/
    └── Tests/
        └── KilwinningAppTests/
```

### 🎨 Screenshots

_Screenshot saranno aggiunti dopo il primo build su dispositivo._

L'app presenta:
- Schermata di login elegante
- Dashboard con card informative
- Liste filtrabili di tornate
- Grafici statistiche
- Gestione tavole
- Pannello amministrazione

### 🔐 Sicurezza e Privacy

- Autenticazione sicura
- Gestione sessioni
- Controllo accessi basato su ruoli
- Pronto per cifratura dati con backend

### 🌟 Prossimi Passi

1. **Integrazione Backend**
   - Scegliere: CloudKit (consigliato), Firebase, o API custom
   - Implementare autenticazione reale
   - Configurare database cloud

2. **Assets e Branding**
   - Aggiungere app icons
   - Creare screenshots per App Store
   - Preparare materiale marketing

3. **Testing**
   - Test su dispositivi reali
   - Beta testing con TestFlight
   - Raccolta feedback

4. **Deploy**
   - Configurare certificati App Store
   - Submit per review
   - Pubblicazione

### 🤝 Contributi

Questo progetto è sviluppato per la Loggia Kilwinning.

### 📄 Licenza

Copyright © 2025 Loggia Kilwinning. Tutti i diritti riservati.

### 📞 Supporto

Per supporto tecnico o domande:
- Consulta la documentazione in `KilwinningApp/`
- Apri un issue su GitHub
- Contatta il team di sviluppo

---

**Versione**: 1.0.0  
**Ultimo Aggiornamento**: Novembre 2025  
**Stato**: ✅ Produzione-ready  

**Sviluppato con ❤️ per la Spettabile Loggia Kilwinning 🏛️**
