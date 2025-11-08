import SwiftUI

/// Tema istituzionale della Loggia Kilwinning
/// Colori: azzurro massonico, bianco e oro
struct AppTheme {
    // Dark Theme Colors
    static let darkBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    static let darkCardBackground = Color(red: 0.15, green: 0.15, blue: 0.17)
    static let darkCardBorder = Color(red: 0.25, green: 0.25, blue: 0.27)
    
    // Light Theme Colors
    static let lightBackground = Color.white
    static let lightCardBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    // Adaptive Colors
    static let adaptiveBackground = Color(UIColor.systemBackground)
    static let adaptiveCardBackground = Color(UIColor.secondarySystemBackground)
    static let adaptiveText = Color(UIColor.label)
    static let adaptiveSecondaryText = Color(UIColor.secondaryLabel)
    
    // Colori primari (mantenuti per compatibilità)
    static let masonicBlue = Color(red: 0.0, green: 0.2, blue: 0.4)
    static let masonicLightBlue = Color(red: 0.4, green: 0.6, blue: 0.9)
    static let masonicGold = Color(red: 0.85, green: 0.65, blue: 0.13)
    static let white = Color.white
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    // Colori di sfondo (mantenuti per compatibilità)
    static let background = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let cardBackground = Color.white
    
    // Colori di stato
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // Ombre
    static let cardShadow = Color.black.opacity(0.1)
    
    // Gradiente principale
    static let primaryGradient = LinearGradient(
        colors: [masonicBlue, masonicLightBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Gradiente oro
    static let goldGradient = LinearGradient(
        colors: [masonicGold, Color(red: 1.0, green: 0.85, blue: 0.4)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Card Colors per le diverse sezioni
    static let tornateCardGradient = LinearGradient(
        colors: [Color(red: 0.2, green: 0.4, blue: 0.6), Color(red: 0.15, green: 0.3, blue: 0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let presenzeCardGradient = LinearGradient(
        colors: [Color(red: 0.6, green: 0.3, blue: 0.4), Color(red: 0.5, green: 0.2, blue: 0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let bibliotecaCardGradient = LinearGradient(
        colors: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.7, green: 0.4, blue: 0.15)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let tavoleCardGradient = LinearGradient(
        colors: [Color(red: 0.5, green: 0.2, blue: 0.6), Color(red: 0.4, green: 0.15, blue: 0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let statisticheCardGradient = LinearGradient(
        colors: [Color(red: 0.2, green: 0.6, blue: 0.4), Color(red: 0.15, green: 0.5, blue: 0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let ritualiCardGradient = LinearGradient(
        colors: [Color(red: 0.3, green: 0.5, blue: 0.8), Color(red: 0.2, green: 0.4, blue: 0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// Estensioni per modificatori comuni
extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: AppTheme.cardShadow, radius: 8, x: 0, y: 4)
    }
    
    func sectionHeaderStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(AppTheme.masonicBlue)
            .padding(.vertical, 8)
    }
}
