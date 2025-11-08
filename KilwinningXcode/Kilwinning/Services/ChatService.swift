import Foundation
import Combine

/// Servizio per la gestione della chat
class ChatService: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var messaggi: [MessaggioChat] = []
    
    @available(*, deprecated, message: "Usa dependency injection con ChatService() invece di .shared")
    static let shared = ChatService()
    
    private let networkService: NetworkService
    private var useMockData = false
    
    nonisolated init(networkService: NetworkService = NetworkService()) {
        self.networkService = networkService
        MainActor.assumeIsolated {
            loadMockData()
        }
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutte le chat rooms
    func fetchChatRooms() async {
        do {
            let dtos = try await networkService.fetchChatRooms()
            chatRooms = dtos.compactMap { convertToChatRoom(from: $0) }
            useMockData = false
        } catch {
            print("Error fetching chat rooms from API: \(error). Using mock data.")
            useMockData = true
            // Mock data already loaded in init
        }
    }
    
    /// Ottieni i messaggi di una chat
    func fetchMessaggi(for chatId: Int) async -> [MessaggioChat] {
        if useMockData {
            return messaggi.filter { $0.idChat == chatId }.sorted { $0.timestamp < $1.timestamp }
        }
        
        do {
            let dtos = try await networkService.fetchChatMessages(chatId: chatId)
            let messages = dtos.compactMap { convertToMessaggioChat(from: $0) }
            
            // Update local cache
            messaggi.removeAll { $0.idChat == chatId }
            messaggi.append(contentsOf: messages)
            
            return messages.sorted { $0.timestamp < $1.timestamp }
        } catch {
            print("Error fetching messages from API: \(error). Using mock data.")
            return messaggi.filter { $0.idChat == chatId }.sorted { $0.timestamp < $1.timestamp }
        }
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
        if useMockData {
            // Mock implementation
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
        } else {
            do {
                // Note: This requires mapping UUID to Int IDs from the backend
                // For now, we'll use a placeholder ID
                let _ = try await networkService.sendMessage(chatId: chatId, mittenteId: 1, testo: testo)
                
                // Refresh messages
                let _ = await fetchMessaggi(for: chatId)
            } catch {
                print("Error sending message: \(error)")
                // Fall back to local state update
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
            }
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
    
    // MARK: - DTO Converters
    
    private func convertToChatRoom(from dto: ChatRoomDTO) -> ChatRoom? {
        let dateFormatter = ISO8601DateFormatter()
        guard let dataCreazione = dateFormatter.date(from: dto.data_creazione) else {
            print("Failed to parse date: \(dto.data_creazione)")
            return nil
        }
        
        let ultimoAggiornamento: Date
        if let ultimoMsg = dto.ultimo_messaggio,
           let date = dateFormatter.date(from: ultimoMsg) {
            ultimoAggiornamento = date
        } else {
            ultimoAggiornamento = dataCreazione
        }
        
        return ChatRoom(
            id: dto.id,
            titolo: dto.nome_chat,
            tipo: .gruppo, // Default to gruppo, can be enhanced later
            ultimoMessaggio: dto.ultimo_messaggio ?? "",
            ultimoAggiornamento: ultimoAggiornamento,
            nonLetti: 0 // This would need additional API support to track per-user
        )
    }
    
    private func convertToMessaggioChat(from dto: ChatMessageDTO) -> MessaggioChat? {
        let dateFormatter = ISO8601DateFormatter()
        guard let timestamp = dateFormatter.date(from: dto.data_invio) else {
            print("Failed to parse date: \(dto.data_invio)")
            return nil
        }
        
        let stato: MessaggioStato = dto.letto == 1 ? .letto : .ricevuto
        
        // TODO: CRITICAL - Implement proper UUID to Int ID mapping
        // This creates a random UUID which causes data inconsistency
        // For now, we log a warning. This should throw an error once user management is in place.
        print("Warning: Creating MessaggioChat with random UUID. Proper ID mapping needed.")
        
        return MessaggioChat(
            id: dto.id,
            idChat: dto.id_chat,
            idMittente: UUID(), // FIXME: Requires proper Int->UUID mapping from backend
            testo: dto.testo,
            timestamp: timestamp,
            stato: stato
        )
    }
}
