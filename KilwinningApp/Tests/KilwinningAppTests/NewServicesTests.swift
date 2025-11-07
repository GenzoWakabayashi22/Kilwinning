import XCTest
@testable import KilwinningApp

@MainActor
final class AudioServiceTests: XCTestCase {
    var audioService: AudioService!
    
    override func setUp() {
        super.setUp()
        audioService = AudioService.shared
    }
    
    func testFetchDiscussioniForTornata() async {
        let tornataId = UUID()
        let discussione = AudioDiscussione(
            id: 1,
            idTornata: tornataId,
            fratelloIntervento: "Test",
            titoloIntervento: "Test Audio",
            audioURL: "https://test.com/audio.mp3"
        )
        
        await audioService.addDiscussione(discussione)
        
        let result = await audioService.fetchDiscussioni(for: tornataId)
        XCTAssertTrue(result.contains { $0.id == 1 })
    }
    
    func testAddDiscussione() async {
        let discussione = AudioDiscussione(
            id: 99,
            idTornata: UUID(),
            fratelloIntervento: "Test",
            titoloIntervento: "New Audio",
            audioURL: "https://test.com/new.mp3"
        )
        
        await audioService.addDiscussione(discussione)
        
        XCTAssertTrue(audioService.discussioni.contains { $0.id == 99 })
    }
}

@MainActor
final class LibraryServiceTests: XCTestCase {
    var libraryService: LibraryService!
    
    override func setUp() {
        super.setUp()
        libraryService = LibraryService.shared
    }
    
    func testSearchLibri() {
        let results = libraryService.searchLibri(query: "Simbolismo")
        XCTAssertTrue(results.count > 0)
        XCTAssertTrue(results.allSatisfy { 
            $0.titolo.lowercased().contains("simbolismo") || 
            $0.autore.lowercased().contains("simbolismo") ||
            $0.categoria.lowercased().contains("simbolismo")
        })
    }
    
    func testSearchLibriEmpty() {
        let results = libraryService.searchLibri(query: "")
        XCTAssertEqual(results.count, libraryService.libri.count)
    }
    
    func testFilterLibriByStato() {
        let disponibili = libraryService.filterLibri(byStato: .disponibile)
        XCTAssertTrue(disponibili.allSatisfy { $0.stato == .disponibile })
        
        let inPrestito = libraryService.filterLibri(byStato: .inPrestito)
        XCTAssertTrue(inPrestito.allSatisfy { $0.stato == .inPrestito })
    }
    
    func testFetchPrestitiForBrother() {
        let brotherId = UUID()
        let prestiti = libraryService.fetchPrestiti(for: brotherId)
        
        // Inizialmente dovrebbe essere vuoto per un nuovo ID
        XCTAssertEqual(prestiti.count, 0)
    }
    
    func testRichediPrestito() async throws {
        // Trova un libro disponibile
        guard let libro = libraryService.libri.first(where: { $0.stato == .disponibile }) else {
            XCTFail("Nessun libro disponibile per il test")
            return
        }
        
        let brotherId = UUID()
        try await libraryService.richediPrestito(libroId: libro.id, fratelloId: brotherId)
        
        // Verifica che il prestito sia stato creato
        let prestiti = libraryService.fetchPrestiti(for: brotherId)
        XCTAssertEqual(prestiti.count, 1)
        XCTAssertEqual(prestiti.first?.idLibro, libro.id)
        
        // Verifica che lo stato del libro sia cambiato
        let libroAggiornato = libraryService.libri.first { $0.id == libro.id }
        XCTAssertEqual(libroAggiornato?.stato, .inPrestito)
    }
}

@MainActor
final class ChatServiceTests: XCTestCase {
    var chatService: ChatService!
    
    override func setUp() {
        super.setUp()
        chatService = ChatService.shared
    }
    
    func testFetchMessaggi() async {
        let chatId = 1
        let messaggi = await chatService.fetchMessaggi(for: chatId)
        
        XCTAssertTrue(messaggi.allSatisfy { $0.idChat == chatId })
    }
    
    func testInviaMessaggio() async {
        let chatId = 1
        let mittente = UUID()
        let testo = "Test messaggio"
        
        let initialCount = chatService.messaggi.count
        await chatService.inviaMessaggio(chatId: chatId, mittente: mittente, testo: testo)
        
        XCTAssertEqual(chatService.messaggi.count, initialCount + 1)
        XCTAssertTrue(chatService.messaggi.contains { $0.testo == testo })
    }
    
    func testGetUnreadCount() {
        let brotherId = UUID()
        let count = chatService.getUnreadCount(for: brotherId)
        
        // Il conteggio dovrebbe essere >= 0
        XCTAssertGreaterThanOrEqual(count, 0)
    }
}

@MainActor
final class NotificationServiceTests: XCTestCase {
    var notificationService: NotificationService!
    
    override func setUp() {
        super.setUp()
        notificationService = NotificationService.shared
    }
    
    func testFetchNotificheNonLette() {
        let nonLette = notificationService.fetchNotificheNonLette()
        XCTAssertTrue(nonLette.allSatisfy { !$0.letto })
    }
    
    func testAddNotifica() async {
        let notifica = Notification(
            id: 999,
            tipo: .nuovaTornata,
            titolo: "Test",
            messaggio: "Test messaggio",
            dataCreazione: Date(),
            letto: false
        )
        
        await notificationService.addNotifica(notifica)
        
        XCTAssertTrue(notificationService.notifiche.contains { $0.id == 999 })
    }
    
    func testSegnaComeLetta() async {
        // Trova una notifica non letta
        guard let notifica = notificationService.notifiche.first(where: { !$0.letto }) else {
            // Crea una notifica per il test
            let testNotifica = Notification(
                id: 888,
                tipo: .nuovaTornata,
                titolo: "Test",
                messaggio: "Test",
                dataCreazione: Date(),
                letto: false
            )
            await notificationService.addNotifica(testNotifica)
            
            await notificationService.segnaComeLetta(888)
            let notificaLetta = notificationService.notifiche.first { $0.id == 888 }
            XCTAssertTrue(notificaLetta?.letto ?? false)
            return
        }
        
        await notificationService.segnaComeLetta(notifica.id)
        
        let notificaLetta = notificationService.notifiche.first { $0.id == notifica.id }
        XCTAssertTrue(notificaLetta?.letto ?? false)
    }
    
    func testNotificaNuovaTornata() async {
        let initialCount = notificationService.notifiche.count
        await notificationService.notificaNuovaTornata(tornata: "Test Tornata", data: "01/01/2025")
        
        XCTAssertEqual(notificationService.notifiche.count, initialCount + 1)
        XCTAssertTrue(notificationService.notifiche.first?.tipo == .nuovaTornata)
    }
}
