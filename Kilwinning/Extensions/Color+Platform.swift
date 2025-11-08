import SwiftUI

// Cross-platform helpers: expose system colors as `Color` in a platform-safe way
extension Color {
    static var systemBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }

    static var systemGray6: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #else
        return Color(NSColor.controlBackgroundColor)
        #endif
    }

    static var systemGroupedBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #else
        return Color(NSColor.windowBackgroundColor)
        #endif
    }

    static var systemGray: Color {
        #if os(iOS)
        return Color(UIColor.systemGray)
        #else
        return Color(NSColor.systemGray)
        #endif
    }

    // Add additional mappings as needed (label, secondaryLabel, systemBlue, etc.)
}
