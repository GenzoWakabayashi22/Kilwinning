import SwiftUI

/// Vista delle notifiche
struct NotificheView: View {
    @EnvironmentObject var notificationService: NotificationService
    @State private var showOnlyUnread = false
    
    var filteredNotifiche: [Notification] {
        if showOnlyUnread {
            return notificationService.fetchNotificheNonLette()
        }
        return notificationService.notifiche
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "bell.fill")
                    .font(.title)
                    .foregroundColor(AppTheme.masonicGold)
                
                Text("Notifiche")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.masonicBlue)
                
                Spacer()
                
                // Badge non lette
                if notificationService.nonLette > 0 {
                    Text("\(notificationService.nonLette)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.error)
                        .cornerRadius(10)
                }
                
                // Pulsante segna tutte come lette
                if notificationService.nonLette > 0 {
                    Button(action: {
                        Task {
                            await notificationService.segnaTutteComeLette()
                        }
                    }) {
                        Text("Segna tutte")
                            .font(.caption)
                            .foregroundColor(AppTheme.masonicBlue)
                    }
                }
            }
            .padding()
            // Platform-specific background color
            #if os(iOS)
            .background(Color(.systemBackground))
            #else
            .background(Color(NSColor.windowBackgroundColor))
            #endif
            
            // Filtro
            HStack {
                FilterChip(
                    title: "Tutte",
                    isSelected: !showOnlyUnread,
                    action: { showOnlyUnread = false }
                )
                
                FilterChip(
                    title: "Non Lette",
                    isSelected: showOnlyUnread,
                    action: { showOnlyUnread = true }
                )
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Lista notifiche
            if filteredNotifiche.isEmpty {
                EmptyStateView(
                    icon: "bell.slash",
                    message: showOnlyUnread ? "Nessuna notifica non letta" : "Nessuna notifica"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredNotifiche, id: \.id) { notifica in
                            NotificaRow(notifica: notifica)
                            
                            if notifica.id != filteredNotifiche.last?.id {
                                Divider()
                                    .padding(.leading, 70)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Riga per ogni notifica
struct NotificaRow: View {
    let notifica: Notification
    @EnvironmentObject var notificationService: NotificationService
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icona tipo notifica
            ZStack {
                Circle()
                    // Platform-specific background color
                    #if os(iOS)
                    .fill(notifica.letto ? Color(.systemGray5) : AppTheme.masonicBlue.opacity(0.2))
                    #else
                    .fill(notifica.letto ? Color(NSColor.controlBackgroundColor) : AppTheme.masonicBlue.opacity(0.2))
                    #endif
                    .frame(width: 48, height: 48)
                
                Image(systemName: tipoIcon)
                    .font(.title3)
                    .foregroundColor(notifica.letto ? .gray : AppTheme.masonicBlue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(notifica.titolo)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fontWeight(notifica.letto ? .regular : .bold)
                    
                    Spacer()
                    
                    Text(notifica.relativeTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(notifica.messaggio)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
                
                // Badge tipo
                Text(notifica.tipo.rawValue)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tipoColor)
                    .cornerRadius(6)
            }
            
            // Indicatore non letta
            if !notifica.letto {
                Circle()
                    .fill(AppTheme.masonicBlue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        // Platform-specific background color
        #if os(iOS)
        .background(notifica.letto ? Color(.systemBackground) : AppTheme.masonicBlue.opacity(0.05))
        #else
        .background(notifica.letto ? Color(NSColor.windowBackgroundColor) : AppTheme.masonicBlue.opacity(0.05))
        #endif
        .onTapGesture {
            if !notifica.letto {
                Task {
                    await notificationService.segnaComeLetta(notifica.id)
                }
            }
        }
        .contextMenu {
            if !notifica.letto {
                Button(action: {
                    Task {
                        await notificationService.segnaComeLetta(notifica.id)
                    }
                }) {
                    Label("Segna come letta", systemImage: "checkmark.circle")
                }
            }
            
            Button(role: .destructive, action: {
                Task {
                    await notificationService.eliminaNotifica(notifica.id)
                }
            }) {
                Label("Elimina", systemImage: "trash")
            }
        }
    }
    
    private var tipoIcon: String {
        switch notifica.tipo {
        case .nuovaTornata, .tornataModificata:
            return "calendar"
        case .nuovaDiscussione:
            return "waveform"
        case .nuovaTavola:
            return "doc.text"
        case .nuovoLibro, .libroRestituito:
            return "book"
        case .nuovoMessaggio:
            return "message"
        }
    }
    
    private var tipoColor: Color {
        switch notifica.tipo {
        case .nuovaTornata, .tornataModificata:
            return AppTheme.masonicBlue
        case .nuovaDiscussione:
            return AppTheme.masonicGold
        case .nuovaTavola:
            return .purple
        case .nuovoLibro, .libroRestituito:
            return .green
        case .nuovoMessaggio:
            return .orange
        }
    }
}

#Preview {
    NotificheView()
}
