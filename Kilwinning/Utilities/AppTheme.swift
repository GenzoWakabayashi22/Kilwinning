import SwiftUI

/// Tema istituzionale della Loggia Kilwinning
/// Colori: azzurro massonico, bianco e oro
struct AppTheme {
    // Colori primari
    static let masonicBlue = Color(red: 0.2, green: 0.4, blue: 0.7)
    static let masonicLightBlue = Color(red: 0.4, green: 0.6, blue: 0.9)
    static let masonicGold = Color(red: 0.85, green: 0.65, blue: 0.13)
    static let white = Color.white
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.97)
    
    // Colori di sfondo
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
