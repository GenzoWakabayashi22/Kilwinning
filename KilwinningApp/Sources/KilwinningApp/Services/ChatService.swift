import Foundation
import Combine

/// Servizio per la gestione della chat
@MainActor
class ChatService: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var messaggi: [MessaggioChat] = []
    
    static let shared = ChatService()
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutte le chat rooms
    func fetchChatRooms() async {
        // TODO: Implementare chiamata reale a backend o WebSocket
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
    
    /// Ottieni i messaggi di una chat
    func fetchMessaggi(for chatId: Int) async -> [MessaggioChat] {
        // TODO: Implementare chiamata reale a backend
        try? await Task.sleep(nanoseconds: 500_000_000)
        return messaggi.filter { $0.idChat == chatId }.sorted { $0.timestamp < $1.timestamp }
    }
    
    /// Ottieni il numero di messaggi non letti
    func getUnreadCount(for brotherId: UUID) -> Int {
        // Calcola quante chat hanno messaggi non letti
        return chatRooms.reduce(0) { $0 + $1.nonLetti }
    }
    
    // MARK: - CRUD Operations - Chat Rooms
    
    /// Crea una nuova chat room
    func createChatRoom(_ chatRoom: ChatRoom) async {
        // TODO: Implementare chiamata reale a backend
        chatRooms.append(chatRoom)
    }
    
    /// Aggiorna una chat room
    func updateChatRoom(_ chatRoom: ChatRoom) async {
        // TODO: Implementare chiamata reale a backend
        if let index = chatRooms.firstIndex(where: { $0.id == chatRoom.id }) {
            chatRooms[index] = chatRoom
        }
    }
    
    // MARK: - CRUD Operations - Messaggi
    
    /// Invia un messaggio
    func inviaMessaggio(chatId: Int, mittente: UUID, testo: String) async {
        // TODO: Implementare chiamata reale a backend o WebSocket
        let newId = (messaggi.map { $0.id }.max() ?? 0) + 1
        let messaggio = MessaggioChat(
            id: newId,
            idChat: chatId,
            idMittente: mittente,
            testo: testo,
            timestamp: Date(),
            stato: .inviato
        )
        
        messaggi.append(messaggio)
        
        // Aggiorna la chat room
        if let index = chatRooms.firstIndex(where: { $0.id == chatId }) {
            chatRooms[index].ultimoMessaggio = testo
            chatRooms[index].ultimoAggiornamento = Date()
        }
    }
    
    /// Segna messaggio come letto
    func segnaComeLetto(_ messaggioId: Int) async {
        // TODO: Implementare chiamata reale a backend
        if let index = messaggi.firstIndex(where: { $0.id == messaggioId }) {
            messaggi[index].stato = .letto
        }
    }
    
    /// Segna tutti i messaggi di una chat come letti
    func segnaTuttiComeLetti(chatId: Int) async {
        // TODO: Implementare chiamata reale a backend
        for i in messaggi.indices {
            if messaggi[i].idChat == chatId && messaggi[i].stato != .letto {
                messaggi[i].stato = .letto
            }
        }
        
        // Azzera il contatore non letti della chat
        if let index = chatRooms.firstIndex(where: { $0.id == chatId }) {
            chatRooms[index].nonLetti = 0
        }
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Chat rooms di esempio
        chatRooms = [
            ChatRoom(
                id: 1,
                titolo: "Loggia Kilwinning",
                tipo: .gruppo,
                ultimoMessaggio: "La prossima tornata è confermata per il 25 novembre",
                ultimoAggiornamento: Date(),
                nonLetti: 2
            ),
            ChatRoom(
                id: 2,
                titolo: "Comitato Tavole",
                tipo: .gruppo,
                ultimoMessaggio: "Ho completato la mia tavola sul simbolismo",
                ultimoAggiornamento: Calendar.current.date(byAdding: .hour, value: -3, to: Date()),
                nonLetti: 0
            )
        ]
        
        // Messaggi di esempio per la chat 1
        let now = Date()
        messaggi = [
            MessaggioChat(
                id: 1,
                idChat: 1,
                idMittente: UUID(), // Placeholder
                testo: "Fratelli, ricordo che la prossima tornata è prevista per il 25 novembre",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: now)!,
                stato: .letto
            ),
            MessaggioChat(
                id: 2,
                idChat: 1,
                idMittente: UUID(), // Placeholder - altro fratello
                testo: "Grazie della comunicazione, Ven.mo",
                timestamp: Calendar.current.date(byAdding: .hour, value: -1, to: now)!,
                stato: .letto
            ),
            MessaggioChat(
                id: 3,
                idChat: 1,
                idMittente: UUID(), // Placeholder
                testo: "La prossima tornata è confermata per il 25 novembre",
                timestamp: now,
                stato: .ricevuto
            )
        ]
    }
}
