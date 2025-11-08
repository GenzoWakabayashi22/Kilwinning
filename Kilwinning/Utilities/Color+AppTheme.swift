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
    
    /// Colore per i campi o card secondarie (equivalente a systemGray6)
    static var appSecondaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
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
}
