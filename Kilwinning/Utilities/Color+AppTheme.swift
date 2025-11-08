import SwiftUI

extension Color {
    
    /// Background principale dell'app (compatibile iOS + macOS)
    static var appBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.white
        #endif
    }
    
    /// Colore per superfici secondarie (card, form, campi)
    /// Equivalente a systemGray6 su iOS
    static var appSecondaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
    
    /// Colore grigio neutro (equivalente a systemGray)
    static var appGray: Color {
        #if os(iOS)
        return Color(UIColor.systemGray)
        #elseif os(macOS)
        return Color(NSColor.systemGray)
        #else
        return Color.gray
        #endif
    }
    
    /// Colore per separatori o linee sottili
    static var appSeparator: Color {
        #if os(iOS)
        return Color(UIColor.separator)
        #elseif os(macOS)
        return Color.gray.opacity(0.3)
        #else
        return Color.gray
        #endif
    }
    
    /// Colore per sfondi accentati o contrastanti (opzionale)
    static var appAccentBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #elseif os(macOS)
        return Color(NSColor.underPageBackgroundColor)
        #else
        return Color.gray.opacity(0.15)
        #endif
    }
}
