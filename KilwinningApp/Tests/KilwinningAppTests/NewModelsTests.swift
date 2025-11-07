import XCTest
@testable import KilwinningApp

final class AudioDiscussioneTests: XCTestCase {
    
    func testAudioDiscussioneCreation() {
        let tornataId = UUID()
        let discussione = AudioDiscussione(
            id: 1,
            idTornata: tornataId,
            fratelloIntervento: "Marco Rossi",
            titoloIntervento: "Il Simbolismo della Squadra",
            durata: "15:30",
            audioURL: "https://pcloud.com/audio123.mp3",
            dataUpload: Date()
        )
        
        XCTAssertEqual(discussione.id, 1)
        XCTAssertEqual(discussione.idTornata, tornataId)
        XCTAssertEqual(discussione.fratelloIntervento, "Marco Rossi")
        XCTAssertEqual(discussione.titoloIntervento, "Il Simbolismo della Squadra")
        XCTAssertEqual(discussione.durata, "15:30")
        XCTAssertEqual(discussione.audioURL, "https://pcloud.com/audio123.mp3")
    }
    
    func testAudioDiscussioneFormattedDate() {
        let date = Date()
        let discussione = AudioDiscussione(
            id: 1,
            idTornata: UUID(),
            fratelloIntervento: "Test",
            titoloIntervento: "Test",
            audioURL: "https://test.com/audio.mp3",
            dataUpload: date
        )
        
        XCTAssertFalse(discussione.formattedUploadDate.isEmpty)
    }
}

final class LibroTests: XCTestCase {
    
    func testLibroCreation() {
        let libro = Libro(
            id: 1,
            titolo: "Il Simbolismo Massonico",
            autore: "Jules Boucher",
            anno: "1948",
            categoria: "Simbologia",
            codiceArchivio: "SIM-001",
            stato: .disponibile
        )
        
        XCTAssertEqual(libro.id, 1)
        XCTAssertEqual(libro.titolo, "Il Simbolismo Massonico")
        XCTAssertEqual(libro.autore, "Jules Boucher")
        XCTAssertEqual(libro.stato, .disponibile)
    }
    
    func testLibroStato() {
        XCTAssertEqual(LibroStato.disponibile.rawValue, "Disponibile")
        XCTAssertEqual(LibroStato.inPrestito.rawValue, "In prestito")
    }
}

final class PrestitoTests: XCTestCase {
    
    func testPrestitoCreation() {
        let brotherId = UUID()
        let prestito = Prestito(
            id: 1,
            idLibro: 1,
            idFratello: brotherId,
            dataInizio: Date(),
            dataFine: nil,
            stato: .attivo
        )
        
        XCTAssertEqual(prestito.id, 1)
        XCTAssertEqual(prestito.idLibro, 1)
        XCTAssertEqual(prestito.idFratello, brotherId)
        XCTAssertEqual(prestito.stato, .attivo)
        XCTAssertNil(prestito.dataFine)
    }
    
    func testPrestitoFormattedDates() {
        let dataInizio = Date()
        let prestito = Prestito(
            id: 1,
            idLibro: 1,
            idFratello: UUID(),
            dataInizio: dataInizio,
            dataFine: nil,
            stato: .attivo
        )
        
        XCTAssertFalse(prestito.formattedDataInizio.isEmpty)
        XCTAssertNil(prestito.formattedDataFine)
    }
    
    func testPrestitoStato() {
        XCTAssertEqual(PrestitoStato.attivo.rawValue, "Attivo")
        XCTAssertEqual(PrestitoStato.concluso.rawValue, "Concluso")
    }
}

final class ChatTests: XCTestCase {
    
    func testChatRoomCreation() {
        let chat = ChatRoom(
            id: 1,
            titolo: "Loggia Kilwinning",
            tipo: .gruppo,
            ultimoMessaggio: "Ciao a tutti",
            ultimoAggiornamento: Date(),
            nonLetti: 2
        )
        
        XCTAssertEqual(chat.id, 1)
        XCTAssertEqual(chat.titolo, "Loggia Kilwinning")
        XCTAssertEqual(chat.tipo, .gruppo)
        XCTAssertEqual(chat.nonLetti, 2)
    }
    
    func testChatType() {
        XCTAssertEqual(ChatType.singola.rawValue, "Singola")
        XCTAssertEqual(ChatType.gruppo.rawValue, "Gruppo")
    }
    
    func testMessaggioChatCreation() {
        let mittente = UUID()
        let messaggio = MessaggioChat(
            id: 1,
            idChat: 1,
            idMittente: mittente,
            testo: "Ciao fratello",
            timestamp: Date(),
            stato: .inviato
        )
        
        XCTAssertEqual(messaggio.id, 1)
        XCTAssertEqual(messaggio.idChat, 1)
        XCTAssertEqual(messaggio.idMittente, mittente)
        XCTAssertEqual(messaggio.testo, "Ciao fratello")
        XCTAssertEqual(messaggio.stato, .inviato)
    }
    
    func testMessaggioStato() {
        XCTAssertEqual(MessaggioStato.inviato.rawValue, "Inviato")
        XCTAssertEqual(MessaggioStato.ricevuto.rawValue, "Ricevuto")
        XCTAssertEqual(MessaggioStato.letto.rawValue, "Letto")
    }
}

final class NotificationTests: XCTestCase {
    
    func testNotificationCreation() {
        let notifica = Notification(
            id: 1,
            tipo: .nuovaTornata,
            titolo: "Nuova Tornata",
            messaggio: "È stata programmata una nuova tornata",
            dataCreazione: Date(),
            letto: false
        )
        
        XCTAssertEqual(notifica.id, 1)
        XCTAssertEqual(notifica.tipo, .nuovaTornata)
        XCTAssertEqual(notifica.titolo, "Nuova Tornata")
        XCTAssertFalse(notifica.letto)
    }
    
    func testNotificationType() {
        XCTAssertEqual(NotificationType.nuovaTornata.rawValue, "Nuova Tornata")
        XCTAssertEqual(NotificationType.nuovaDiscussione.rawValue, "Nuova Discussione Audio")
        XCTAssertEqual(NotificationType.nuovaTavola.rawValue, "Nuova Tavola")
        XCTAssertEqual(NotificationType.nuovoLibro.rawValue, "Nuovo Libro")
        XCTAssertEqual(NotificationType.nuovoMessaggio.rawValue, "Nuovo Messaggio")
    }
    
    func testNotificationRelativeTime() {
        let notifica = Notification(
            id: 1,
            tipo: .nuovaTornata,
            titolo: "Test",
            messaggio: "Test",
            dataCreazione: Date(),
            letto: false
        )
        
        XCTAssertEqual(notifica.relativeTime, "Ora")
    }
}
