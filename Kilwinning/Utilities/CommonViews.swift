import SwiftUI

// MARK: - Shared UI Components
// Componenti UI comuni riutilizzabili in tutta l'app
//
// NOTA: PresenceButton richiede PresenceStatus enum dal modulo Models.
// Assicurarsi che il modello Presence.swift sia accessibile quando si usa PresenceButton.

/// Vista per mostrare una riga informativa con label e valore opzionale
struct InfoRow: View {
    let label: String
    let value: String?
    let showBullet: Bool
    
    init(label: String, value: String? = nil, showBullet: Bool = false) {
        self.label = label
        self.value = value
        self.showBullet = showBullet
    }
    
    var body: some View {
        HStack {
            if showBullet {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundColor(AppTheme.masonicBlue)
            }
            
            if let value = value {
                // Key-Value layout
                Text(label + ":")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            } else {
                // Solo label
                Text(label)
                    .font(.subheadline)
            }
        }
    }
}

/// Vista per mostrare uno stato vuoto con icona e messaggio
struct EmptyStateView: View {
    let icon: String
    let message: String
    let iconSize: CGFloat
    let iconColor: Color
    
    init(
        icon: String,
        message: String,
        iconSize: CGFloat = 60,
        iconColor: Color = .gray.opacity(0.5)
    ) {
        self.icon = icon
        self.message = message
        self.iconSize = iconSize
        self.iconColor = iconColor
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: iconSize))
                .foregroundColor(iconColor)
            
            Text(message)
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

/// Pulsante generico per azioni con icona
struct ActionButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isSelected ? color : color.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

/// Pulsante specifico per conferma presenza a tornata
struct PresenceButton: View {
    let status: PresenceStatus
    let isSelected: Bool
    let action: () -> Void
    
    var color: Color {
        switch status {
        case .presente: return AppTheme.success
        case .assente: return AppTheme.error
        case .nonConfermato: return AppTheme.warning
        }
    }
    
    var icon: String {
        switch status {
        case .presente: return "checkmark.circle.fill"
        case .assente: return "xmark.circle.fill"
        case .nonConfermato: return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(status.rawValue)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
            .foregroundColor(isSelected ? .white : color)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? color : backgroundGray)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color, lineWidth: isSelected ? 0 : 2)
            )
        }
    }

    /// Colore di background compatibile iOS/macOS
    private var backgroundGray: Color {
        #if os(iOS)
        return Color(.systemGray6)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }
}
