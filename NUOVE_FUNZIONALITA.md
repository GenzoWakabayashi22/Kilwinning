# Kilwinning App - Nuove Funzionalità

## 📋 Panoramica

Questo documento descrive le nuove funzionalità aggiunte all'applicazione Kilwinning per la gestione delle tornate massoniche.

## 🆕 Funzionalità Implementate

### 1. 🔊 Discussioni Audio

Le discussioni audio permettono di registrare e ascoltare gli interventi dei fratelli durante le tornate.

**Caratteristiche:**
- Audio in streaming da pCloud (nessun download locale)
- Player integrato con controlli avanzati (play/pausa, avanti/indietro 15s, slider)
- Collegamento diretto alla tornata di riferimento
- Metadati completi (fratello, titolo, durata)

**Modelli:**
- `AudioDiscussione`: rappresenta una registrazione audio

**Servizi:**
- `AudioService`: gestione CRUD delle discussioni audio

**Viste:**
- `AudioPlayerView`: player audio integrato con AVPlayer
- Sezione "Discussioni Audio" in `TornataDetailView`

**Utilizzo:**
```swift
// Aggiungere una discussione
let discussione = AudioDiscussione(
    id: 1,
    idTornata: tornataId,
    fratelloIntervento: "Fr. Marco Rossi",
    titoloIntervento: "Il Simbolismo della Squadra",
    durata: "15:30",
    audioURL: "https://pcloud.com/audio.mp3"
)
await audioService.addDiscussione(discussione)
```

### 2. 📜 Tavole con PDF

Le tavole architettoniche ora supportano PDF allegati e collegamenti alle tornate.

**Novità:**
- Campo `pdfURL` per allegare documenti PDF
- Campo `idTornata` per collegare la tavola alla tornata di presentazione
- Visualizzazione PDF integrata con PDFKit
- Pulsante "Vai alla Discussione Audio" per navigare alla tornata correlata

**Viste:**
- `PDFViewerView`: visualizzatore PDF integrato
- `TavolaDetailView`: aggiornata con supporto PDF e link tornata

**Utilizzo:**
```swift
// Creare una tavola con PDF
let tavola = Tavola(
    brotherId: fratelloId,
    title: "Il Simbolismo della Squadra",
    status: .completata,
    pdfURL: "https://example.com/tavola.pdf",
    idTornata: tornataId
)
```

### 3. 📚 Biblioteca

Sistema completo di gestione biblioteca con catalogo e prestiti.

**Caratteristiche:**
- Catalogo libri con ricerca per titolo, autore, categoria
- Filtri per disponibilità
- Sistema prestiti completo
- Gestione amministrativa per il bibliotecario
- Sezione "I miei prestiti" personale

**Modelli:**
- `Libro`: informazioni libro (titolo, autore, anno, categoria, codice archivio)
- `Prestito`: gestione prestiti (date, stato)

**Servizi:**
- `LibraryService`: gestione catalogo e prestiti

**Viste:**
- `BibliotecaView`: catalogo con ricerca e filtri
- `MieiPrestitiView`: gestione prestiti personali
- `LibroDetailView`: dettagli libro con richiesta/restituzione

**Utilizzo:**
```swift
// Richiedere un prestito
try await libraryService.richediPrestito(
    libroId: libro.id,
    fratelloId: fratello.id
)

// Restituire un libro
try await libraryService.restituisciLibro(prestitoId: prestito.id)
```

### 4. 💬 Chat Interna

Sistema di messaggistica istantanea tra fratelli.

**Caratteristiche:**
- Chat singole e di gruppo
- Interfaccia stile WhatsApp con bolle messaggi
- Stato messaggi (inviato, ricevuto, letto)
- Contatore messaggi non letti
- Timestamp e formattazione date intelligente

**Modelli:**
- `ChatRoom`: stanza chat (singola/gruppo)
- `MessaggioChat`: singolo messaggio

**Servizi:**
- `ChatService`: gestione chat e messaggi

**Viste:**
- `ChatView`: elenco chat
- `ChatConversationView`: vista conversazione
- `MessageBubble`: bolle messaggi con stile WhatsApp

**Utilizzo:**
```swift
// Inviare un messaggio
await chatService.inviaMessaggio(
    chatId: chat.id,
    mittente: fratello.id,
    testo: "Ciao fratelli!"
)

// Segnare come letti
await chatService.segnaTuttiComeLetti(chatId: chat.id)
```

### 5. 🔔 Notifiche Interne

Sistema di notifiche in-app con supporto notifiche locali.

**Caratteristiche:**
- Notifiche per eventi (tornate, audio, tavole, libri, chat)
- Badge con contatore non lette
- Notifiche locali con UNUserNotificationCenter
- Gestione permessi automatica
- Tempo relativo intelligente

**Modelli:**
- `Notification`: notifica con tipo, titolo, messaggio

**Servizi:**
- `NotificationService`: gestione notifiche

**Viste:**
- `NotificheView`: elenco notifiche con filtri

**Utilizzo:**
```swift
// Creare notifica per nuova tornata
await notificationService.notificaNuovaTornata(
    tornata: "Il sentiero della saggezza",
    data: "25 novembre 2025"
)

// Richiedere permessi notifiche
let granted = await notificationService.richediPermessi()
```

## 🎨 Integrazione UI

Tutte le nuove funzionalità sono integrate nel menu principale con:

- Tab "Biblioteca" per il catalogo
- Tab "Prestiti" per i prestiti personali
- Tab "Chat" con badge messaggi non letti
- Tab "Notifiche" con badge notifiche non lette
- Tema massonico coerente (blu, bianco, oro)
- Animazioni fluide e transizioni

## 🔧 Architettura Tecnica

### Pattern MVVM
Tutte le funzionalità seguono il pattern MVVM esistente:
- **Model**: dati immutabili con Codable
- **View**: SwiftUI dichiarativo
- **Service**: @ObservableObject con @Published

### Backend Placeholders
Tutti i servizi hanno metodi async/await pronti per integrazione REST:

```swift
// Esempio di placeholder
func fetchDiscussioni(for tornataId: UUID) async -> [AudioDiscussione] {
    // TODO: Implementare chiamata reale a backend
    try? await Task.sleep(nanoseconds: 500_000_000)
    return discussioni.filter { $0.idTornata == tornataId }
}
```

### Compatibilità
- iOS 17.0+
- macOS 14.0+ (Sonoma)
- Pattern universale multipiattaforma

## 📊 Modelli Dati

### AudioDiscussione
```swift
struct AudioDiscussione: Identifiable, Codable {
    let id: Int
    var idTornata: UUID
    var fratelloIntervento: String
    var titoloIntervento: String
    var durata: String?
    var audioURL: String
    var dataUpload: Date
}
```

### Libro & Prestito
```swift
struct Libro: Identifiable, Codable {
    let id: Int
    var titolo: String
    var autore: String
    var anno: String
    var categoria: String
    var codiceArchivio: String
    var stato: LibroStato
    var copertinaURL: String?
}

struct Prestito: Identifiable, Codable {
    let id: Int
    var idLibro: Int
    var idFratello: UUID
    var dataInizio: Date
    var dataFine: Date?
    var stato: PrestitoStato
}
```

### ChatRoom & MessaggioChat
```swift
struct ChatRoom: Identifiable, Codable {
    let id: Int
    var titolo: String
    var tipo: ChatType // singola/gruppo
    var ultimoMessaggio: String?
    var ultimoAggiornamento: Date?
    var nonLetti: Int
}

struct MessaggioChat: Identifiable, Codable {
    let id: Int
    var idChat: Int
    var idMittente: UUID
    var testo: String
    var timestamp: Date
    var stato: MessaggioStato
}
```

### Notification
```swift
struct Notification: Identifiable, Codable {
    let id: Int
    var tipo: NotificationType
    var titolo: String
    var messaggio: String
    var dataCreazione: Date
    var letto: Bool
    var idRiferimento: String?
}
```

## 🧪 Testing

Sono stati aggiunti test unitari completi per:
- Tutti i nuovi modelli
- Tutti i nuovi servizi
- Operazioni CRUD
- Funzionalità di ricerca e filtro

Esegui i test con:
```bash
swift test
```

## 🚀 Prossimi Passi

### Integrazione Backend
1. Configurare endpoint REST API
2. Sostituire placeholder con chiamate reali
3. Implementare autenticazione token-based
4. Aggiungere gestione errori network

### WebSocket per Chat
Per messaggistica real-time:
```swift
// Esempio integrazione WebSocket
class ChatService: ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    
    func connectWebSocket() {
        let url = URL(string: "wss://api.kilwinning.com/chat")!
        webSocket = URLSession.shared.webSocketTask(with: url)
        webSocket?.resume()
        receiveMessage()
    }
}
```

### Push Notifications
Configurare APNs per notifiche push:
1. Creare certificato APNs
2. Configurare backend per inviare notifiche
3. Gestire token device

## 📝 Note Importanti

- **Audio Streaming**: Gli audio sono sempre esterni (pCloud), mai caricati nell'app
- **PDF**: Supporto nativo iOS/macOS, nessuna libreria esterna
- **Mock Data**: Tutti i servizi hanno dati mock per testing
- **Sicurezza**: Preparato per cifratura e autenticazione sicura
- **Scalabilità**: Architettura pronta per migliaia di utenti

## 📞 Supporto

Per domande o problemi:
1. Consulta la documentazione esistente in `KilwinningApp/`
2. Verifica i test unitari per esempi di utilizzo
3. Apri un issue su GitHub

---

**Versione**: 2.0.0  
**Data Aggiornamento**: Novembre 2025  
**Sviluppato per**: Spettabile Loggia Kilwinning 🏛️
