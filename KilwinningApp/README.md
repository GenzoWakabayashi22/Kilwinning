# Sistema Gestione Tornate – Loggia Kilwinning

App SwiftUI multi-piattaforma (iOS 17+ e macOS 14+) per la gestione delle tornate, presenze e tavole architettoniche della Spettabile Loggia Kilwinning.

## 🏛️ Caratteristiche Principali

### 🔐 Autenticazione
- Login sicuro con email e password
- Registrazione nuovi fratelli
- Recupero password
- Sessione persistente

### 📊 Dashboard Personale
- Informazioni fratello (nome, grado, ruolo istituzionale)
- Statistiche presenze personali
- Tornate partecipate
- Presenze consecutive e record personali

### 📅 Gestione Tornate
- Elenco completo delle tornate (ordinarie e cerimonie)
- Visualizzazione dettagli tornata
- Conferma presenza/assenza in tempo reale
- Filtri per anno e tipo
- Informazioni su luogo, orario, relatore

### 📈 Presenze
- Grafici mensili delle presenze
- Statistiche annuali complete
- Record personali
- Storico presenze

### 📝 Tavole Architettoniche
- Elenco tavole personali
- Stati: Completata, Programmato, In Preparazione
- Visualizzazione contenuto
- Conteggio annuale

### ⚙️ Amministrazione
(Solo per utenti con permessi - Ven.mo Maestro, Segretario)
- Gestione fratelli
- Creazione nuove tornate
- Statistiche loggia
- Generazione report (futuro)

## 🎨 Design

Il design segue le linee guida Apple con:
- **Colori istituzionali**: Azzurro massonico, bianco, oro
- **Font**: San Francisco (sistema)
- **Interfaccia**: Elegante, sobria e professionale
- **Tema**: Richiami simbolici massonici (colonne, compassi)

## 🛠️ Tecnologie

- **Linguaggio**: Swift
- **Framework**: SwiftUI
- **Piattaforme**: iOS 17+, macOS 14+
- **Architettura**: MVVM
- **Gestione Dati**: Preparato per CloudKit o Firebase
- **Package Manager**: Swift Package Manager

## 📁 Struttura del Progetto

```
KilwinningApp/
├── Sources/KilwinningApp/
│   ├── Models/              # Modelli dati
│   │   ├── Brother.swift    # Fratello della loggia
│   │   ├── Tornata.swift    # Riunione/tornata
│   │   ├── Presence.swift   # Presenza a tornata
│   │   └── Tavola.swift     # Tavola architettonica
│   ├── Views/               # Interfacce utente
│   │   ├── LoginView.swift
│   │   ├── RegistrationView.swift
│   │   ├── DashboardView.swift
│   │   ├── HomeContentView.swift
│   │   ├── TornateListView.swift
│   │   ├── PresenzeView.swift
│   │   ├── TavoleView.swift
│   │   └── AdministrationView.swift
│   ├── Services/            # Servizi e logica business
│   │   ├── AuthenticationService.swift
│   │   └── DataService.swift
│   ├── Utilities/           # Utilità e helpers
│   │   └── AppTheme.swift   # Tema e colori
│   └── KilwinningApp.swift  # Entry point
└── Tests/KilwinningAppTests/
    ├── BrotherTests.swift
    ├── TornataTests.swift
    └── PresenceTests.swift
```

## 🚀 Compilazione e Test

### Prerequisiti
- Xcode 15.0 o superiore
- macOS Sonoma 14.0 o superiore
- Swift 5.9+

### Build e Test

```bash
cd KilwinningApp

# Build del progetto
swift build

# Esecuzione test
swift test
```

### Apertura del Progetto

Questo progetto usa **Swift Package Manager** (SPM) e non ha un file `.xcodeproj` alla root.

#### Opzione 1: Aprire con Xcode (Consigliato)
```bash
# Apri direttamente il Package.swift con Xcode
open Package.swift
```

Xcode riconoscerà automaticamente il progetto Swift Package e lo aprirà correttamente.

#### Opzione 2: Doppio click su Package.swift
Dal Finder, fai doppio click sul file `Package.swift` e Xcode lo aprirà automaticamente.

#### Opzione 3: Aprire da Xcode
1. Apri Xcode
2. File → Open...
3. Seleziona il file `Package.swift` o la cartella `KilwinningApp`

#### Opzione 4: Generare un progetto Xcode (deprecato)
```bash
# Nota: swift package generate-xcodeproj è deprecato in Swift 5.9+
# Usa invece una delle opzioni sopra
swift package generate-xcodeproj
```

**Nota**: Il comando `generate-xcodeproj` è deprecato nelle versioni recenti di Swift. Xcode può aprire direttamente i Swift Package.

## 📱 Utilizzo

### Login Demo
- **Email**: demo@kilwinning.it
- **Password**: demo123

### Funzionalità Disponibili

1. **Dashboard Home**:
   - Visualizza informazioni personali
   - Controlla statistiche presenze
   - Vedi tornate partecipate

2. **Sezione Tornate**:
   - Naviga tra le tornate future e passate
   - Conferma presenza o assenza
   - Visualizza dettagli completi

3. **Sezione Presenze**:
   - Analizza statistiche annuali
   - Visualizza grafici mensili
   - Controlla record personali

4. **Sezione Tavole**:
   - Gestisci le tue tavole architettoniche
   - Monitora lo stato di avanzamento
   - Visualizza contenuti

5. **Amministrazione** (solo admin):
   - Gestisci fratelli
   - Crea nuove tornate
   - Visualizza statistiche loggia

## 🔄 Integrazione Backend

Il progetto è preparato per l'integrazione con:
- **CloudKit** (Apple) - consigliato per ecosistema Apple
- **Firebase** - alternativa cross-platform
- **API REST PHP/MySQL** - backend custom

I servizi `AuthenticationService` e `DataService` includono placeholder per chiamate API che devono essere implementate.

## 📊 Informazioni Loggia

- **Nome**: Spettabile Loggia Kilwinning
- **Sede**: Via XX Settembre 22, Tolfa (RM)
- **Calendario**:
  - Secondo martedì del mese, ore 19:30
  - Quarto giovedì del mese, ore 19:30
- **Conferme**: Entro 5 giorni prima della tornata

## 🔐 Sicurezza

- Autenticazione sicura
- Sessioni persistenti con UserDefaults (da migliorare con Keychain)
- Gestione permessi basata su ruoli
- Pronto per cifratura dati con backend

## 📝 TODO / Roadmap

- [ ] Integrazione CloudKit/Firebase per persistenza dati cloud
- [ ] Implementazione completa autenticazione con backend
- [ ] Generazione PDF/CSV per report
- [ ] Notifiche push per promemoria tornate
- [ ] Sincronizzazione multi-dispositivo
- [ ] Widget iOS per tornate imminenti
- [ ] Supporto iPad con layout ottimizzato
- [ ] Dark mode ottimizzato
- [ ] Localizzazione multilingua
- [ ] Accessibilità VoiceOver completa

## 👥 Contributi

Questo progetto è stato sviluppato per la Loggia Kilwinning.

## 📄 Licenza

Copyright © 2025 Loggia Kilwinning. Tutti i diritti riservati.

---

**Nota**: Questa è una versione iniziale dell'applicazione. Per utilizzo in produzione, è necessario:
1. Configurare backend per autenticazione reale
2. Implementare persistenza dati cloud (CloudKit o Firebase)
3. Configurare certificati e profili per distribuzione App Store
4. Completare testing su dispositivi reali
5. Implementare cifratura end-to-end per dati sensibili
