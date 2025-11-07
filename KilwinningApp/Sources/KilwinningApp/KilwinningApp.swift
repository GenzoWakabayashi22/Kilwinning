import SwiftUI

@main
struct KilwinningApp: App {
    @StateObject private var authService = AuthenticationService.shared
    @StateObject private var dataService = DataService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authService)
                .environmentObject(dataService)
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
    }
}

struct ContentView: View {
    @StateObject private var authService = AuthenticationService.shared
    
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
