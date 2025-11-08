import SwiftUI

@main
struct KilwinningApp: App {
    @StateObject private var authService = AuthenticationService()
    @StateObject private var dataService = DataService()
    @StateObject private var notificationService = NotificationService()
    @StateObject private var chatService = ChatService()
    @StateObject private var libraryService = LibraryService()
    @StateObject private var bibliotecaService = BibliotecaService()
    @StateObject private var audioService = AudioService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(dataService)
                .environmentObject(notificationService)
                .environmentObject(chatService)
                .environmentObject(libraryService)
                .environmentObject(bibliotecaService)
                .environmentObject(audioService)
                .onAppear {
                    // Initialize biblioteca service with current user
                    if let fratelloId = authService.currentBrother?.id {
                        bibliotecaService.setCurrentFratello(id: fratelloId)
                    }
                }
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

struct ContentView: View {
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                DashboardView()
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    ContentView()
}
