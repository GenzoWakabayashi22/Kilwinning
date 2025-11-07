import SwiftUI

/// Vista principale della chat
struct ChatView: View {
    @StateObject private var chatService = ChatService.shared
    @EnvironmentObject var authService: AuthenticationService
    @State private var selectedChat: ChatRoom? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "message.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.masonicGold)
                
                Text("Chat Fratelli")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                // Badge messaggi non letti
                if let brotherId = authService.currentBrother?.id,
                   chatService.getUnreadCount(for: brotherId) > 0 {
                    Text("\(chatService.getUnreadCount(for: brotherId))")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.error)
                        .cornerRadius(10)
                }
            }
            .padding()
            // Platform-specific background color
            #if os(iOS)
            .background(Color(.systemBackground))
            #else
            .background(Color(NSColor.windowBackgroundColor))
            #endif
            
            Divider()
            
            // Lista chat
            if chatService.chatRooms.isEmpty {
                EmptyStateView(
                    icon: "message",
                    message: "Nessuna chat disponibile"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(chatService.chatRooms.sorted { ($0.ultimoAggiornamento ?? .distantPast) > ($1.ultimoAggiornamento ?? .distantPast) }, id: \.id) { chat in
                            ChatRoomRow(chat: chat)
                                .onTapGesture {
                                    selectedChat = chat
                                }
                            
                            if chat.id != chatService.chatRooms.last?.id {
                                Divider()
                                    .padding(.leading, 80)
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedChat) { chat in
            ChatConversationView(chat: chat)
        }
    }
}

/// Riga per ogni chat room
struct ChatRoomRow: View {
    let chat: ChatRoom
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(AppTheme.masonicBlue.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: chat.tipo == .gruppo ? "person.3.fill" : "person.fill")
                    .font(.title3)
                    .foregroundColor(AppTheme.masonicBlue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(chat.titolo)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let timestamp = chat.formattedUltimoAggiornamento {
                        Text(timestamp)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                HStack {
                    if let ultimoMessaggio = chat.ultimoMessaggio {
                        Text(ultimoMessaggio)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    } else {
                        Text("Nessun messaggio")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .italic()
                    }
                    
                    Spacer()
                    
                    // Badge non letti
                    if chat.nonLetti > 0 {
                        Text("\(chat.nonLetti)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.masonicBlue)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        // Platform-specific background color
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(NSColor.windowBackgroundColor))
        #endif
    }
}

/// Vista conversazione chat
struct ChatConversationView: View {
    let chat: ChatRoom
    @EnvironmentObject var authService: AuthenticationService
    @StateObject private var chatService = ChatService.shared
    
    @State private var messaggi: [MessaggioChat] = []
    @State private var newMessage = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Lista messaggi
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messaggi) { messaggio in
                                MessageBubble(
                                    messaggio: messaggio,
                                    isCurrentUser: messaggio.idMittente == authService.currentBrother?.id
                                )
                                .id(messaggio.id)
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                }
                
                Divider()
                
                // Input messaggio
                HStack(spacing: 12) {
                    TextField("Scrivi un messaggio...", text: $newMessage, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        // Platform-specific background color
                        #if os(iOS)
                        .background(Color(.systemGray6))
                        #else
                        .background(Color(NSColor.controlBackgroundColor))
                        #endif
                        .cornerRadius(20)
                        .lineLimit(1...5)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(newMessage.isEmpty ? .gray : AppTheme.masonicBlue)
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding()
                // Platform-specific background color
                #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color(NSColor.windowBackgroundColor))
                #endif
            }
            .navigationTitle(chat.titolo)
            // Platform-specific navigation bar display mode (iOS only)
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(chat.titolo)
                            .font(.headline)
                        Text(chat.tipo.rawValue)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .task {
                await loadMessages()
            }
            .onAppear {
                // Segna messaggi come letti
                Task {
                    await chatService.segnaTuttiComeLetti(chatId: chat.id)
                }
            }
        }
    }
    
    private func loadMessages() async {
        messaggi = await chatService.fetchMessaggi(for: chat.id)
        scrollToBottom()
    }
    
    private func sendMessage() {
        guard !newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let brotherId = authService.currentBrother?.id else { return }
        
        let messageText = newMessage
        newMessage = ""
        
        Task {
            await chatService.inviaMessaggio(chatId: chat.id, mittente: brotherId, testo: messageText)
            await loadMessages()
        }
    }
    
    private func scrollToBottom() {
        guard let lastMessage = messaggi.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

/// Bolla messaggio (stile WhatsApp)
struct MessageBubble: View {
    let messaggio: MessaggioChat
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(messaggio.testo)
                    .font(.body)
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    // Platform-specific background color for message bubbles
                    #if os(iOS)
                    .background(isCurrentUser ? AppTheme.masonicBlue : Color(.systemGray5))
                    #else
                    .background(isCurrentUser ? AppTheme.masonicBlue : Color(NSColor.controlBackgroundColor))
                    #endif
                    .cornerRadius(18)
                
                HStack(spacing: 4) {
                    Text(messaggio.formattedTimestamp)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    // Icona stato (solo per messaggi dell'utente corrente)
                    if isCurrentUser {
                        Image(systemName: statoIcon)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if !isCurrentUser {
                Spacer(minLength: 60)
            }
        }
    }
    
    private var statoIcon: String {
        switch messaggio.stato {
        case .inviato:
            return "checkmark"
        case .ricevuto:
            return "checkmark.circle"
        case .letto:
            return "checkmark.circle.fill"
        }
    }
}

#Preview {
    ChatView()
        .environmentObject(AuthenticationService.shared)
}

#Preview("Conversation") {
    ChatConversationView(chat: ChatRoom(
        id: 1,
        titolo: "Loggia Kilwinning",
        tipo: .gruppo
    ))
    .environmentObject(AuthenticationService.shared)
}
