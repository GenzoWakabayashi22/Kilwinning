# Quick Start Guide - Kilwinning App

## 🚀 Avvio Rapido in 5 Minuti

### Per Utenti Mac (Sviluppatori)

#### Step 1: Prerequisiti
```bash
# Verifica versione macOS
sw_vers

# Verifica Xcode (deve essere 15.0+)
xcodebuild -version
```

#### Step 2: Clone e Apertura
```bash
# Clone repository
git clone https://github.com/GenzoWakabayashi22/Kilwinning.git
cd Kilwinning/KilwinningApp

# Apri in Xcode
open Package.swift
```

#### Step 3: Build & Run
1. In Xcode, seleziona il target:
   - **iOS**: Scegli "iPhone 15 Pro" (o altro simulatore)
   - **macOS**: Scegli "My Mac"

2. Premi `Cmd + R` per compilare ed eseguire

3. L'app si aprirà automaticamente

#### Step 4: Login Demo
```
Email: demo@kilwinning.it
Password: demo123
```

#### Step 5: Esplora!
- Naviga tra le sezioni usando la barra superiore
- Conferma presenza alle prossime tornate
- Visualizza statistiche e tavole

---

## 📱 Per Utenti Finali (Fratelli della Loggia)

### Quando l'App sarà su App Store

#### Download
1. Apri App Store su iPhone/iPad/Mac
2. Cerca "Kilwinning"
3. Tocca "Ottieni" / "Download"
4. Installa l'app

#### Primo Accesso
1. Apri l'app "Kilwinning"
2. Tocca "Registrati"
3. Inserisci i tuoi dati:
   - Nome e Cognome
   - Email personale
   - Password sicura
4. Conferma email (riceverai un link)
5. Accedi con le tue credenziali

#### Uso Quotidiano

**Confermare Presenza a una Tornata:**
1. Apri app
2. Vai su "Home"
3. Scorri fino a "Prossime Tornate"
4. Tocca "Presente" per confermare
5. Vedrai "✓ Confermato"

**Visualizzare Statistiche:**
1. Tocca "Presenze" nella barra superiore
2. Vedi le tue statistiche annuali
3. Controlla il grafico mensile
4. Monitora i tuoi record

**Gestire Tavole:**
1. Tocca "Tavole"
2. Vedi la lista delle tue tavole
3. Tocca una tavola per dettagli
4. Controlla lo stato

---

## 🔧 Risoluzione Problemi Rapida

### App non si apre su macOS
```bash
# Pulisci build
rm -rf .build/

# Riapri in Xcode
open Package.swift
```

### Errori di compilazione
```bash
# In Xcode:
# Product → Clean Build Folder (Cmd+Shift+K)
# Poi: Product → Build (Cmd+B)
```

### Login non funziona
- Verifica email e password
- Usa account demo per testare
- Contatta amministratore se necessario

### Dati non si salvano
- Attualmente app in modalità demo
- Backend sarà attivato nella versione finale
- I dati sono temporanei in memoria

---

## 📖 Prossimi Passi

### Per Sviluppatori

1. **Leggi la documentazione completa:**
   - `README.md` - Overview generale
   - `SETUP.md` - Setup dettagliato
   - `DOCUMENTATION.md` - Dettagli tecnici

2. **Configura backend:**
   - Scegli: CloudKit, Firebase o Custom API
   - Aggiorna `AuthenticationService.swift`
   - Aggiorna `DataService.swift`

3. **Personalizza:**
   - Modifica colori in `AppTheme.swift`
   - Aggiungi nuove features
   - Estendi i modelli dati

### Per Amministratori

1. **Setup Loggia:**
   - Crea account amministratore
   - Importa dati fratelli
   - Configura tornate annuali

2. **Gestione Utenti:**
   - Invita fratelli a registrarsi
   - Assegna ruoli
   - Gestisci permessi

3. **Monitoring:**
   - Controlla statistiche loggia
   - Genera report periodici
   - Monitora partecipazione

### Per Fratelli

1. **Profilo:**
   - Completa il tuo profilo
   - Verifica dati personali
   - Aggiorna se necessario

2. **Partecipazione:**
   - Conferma presenza tornate
   - Entro 5 giorni prima
   - Mantieni alta la percentuale

3. **Tavole:**
   - Aggiorna stato tavole
   - Programma presentazioni
   - Carica contenuti

---

## 💡 Tips & Tricks

### Scorciatoie Tastiera (macOS)

```
Cmd + R     = Run app
Cmd + B     = Build
Cmd + U     = Run tests
Cmd + K     = Clean
Cmd + .     = Stop
```

### Funzionalità Nascoste

- **Swipe indietro (iOS)**: Scorri da sinistra per tornare
- **Pull to refresh**: Tira giù per aggiornare dati (futuro)
- **Long press**: Press lungo su tornata per più opzioni (futuro)

### Best Practices Utente

✅ **DO:**
- Conferma presenza appena possibile
- Mantieni profilo aggiornato
- Controlla statistiche regolarmente
- Aggiorna stato tavole

❌ **DON'T:**
- Non condividere password
- Non confermare troppo tardi
- Non ignorare notifiche (quando attive)
- Non lasciare tavole "in preparazione" troppo a lungo

---

## 🆘 Supporto Rapido

### Problemi Comuni

**Q: Non riesco a compilare su Linux/Windows**
A: SwiftUI richiede macOS. Usa un Mac o Mac virtuale.

**Q: L'app non salva i dati**
A: Versione demo - backend verrà implementato.

**Q: Come cambio la password?**
A: Login → Password dimenticata → Segui istruzioni email.

**Q: Non vedo sezione Amministrazione**
A: Solo per utenti con permessi admin.

**Q: Posso usare su Android?**
A: No, app solo per iOS/macOS (Apple ecosystem).

### Contatti

- **Email Supporto**: [da definire]
- **Telefono**: [da definire]
- **GitHub Issues**: https://github.com/GenzoWakabayashi22/Kilwinning/issues

---

## 📅 Roadmap Veloce

### ✅ Completato (v1.0)
- Struttura app completa
- UI e design
- Modelli dati
- Autenticazione base
- Gestione tornate
- Statistiche presenze
- Gestione tavole

### 🔄 In Sviluppo (v1.1)
- Integrazione backend
- CloudKit/Firebase
- Notifiche push
- Sincronizzazione cloud

### 📋 Pianificato (v2.0)
- Widget iOS
- Apple Watch app
- Export PDF/CSV
- Calendario integrato
- Chat interna

---

## 🎓 Tutorial Video (Futuro)

Quando disponibili, tutorial su:
- Primo setup
- Gestione tornate
- Analisi statistiche
- Amministrazione
- Troubleshooting

---

## ✨ Conclusione

Congratulazioni! Ora sei pronto per:

1. ✅ Compilare ed eseguire l'app
2. ✅ Navigare tra le sezioni
3. ✅ Testare le funzionalità
4. ✅ Personalizzare per la tua loggia

**Prossimi passi consigliati:**
1. Leggi `GUIDA_UTENTE.md` per dettagli completi
2. Esplora `DOCUMENTATION.md` per aspetti tecnici
3. Contribuisci con feedback e suggerimenti

---

**Happy Coding! 🎉**

*Versione Quick Start: 1.0*  
*Ultimo aggiornamento: Novembre 2025*
