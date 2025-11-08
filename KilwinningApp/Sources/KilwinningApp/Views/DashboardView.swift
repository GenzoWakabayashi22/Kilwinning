import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var dataService: DataService
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header con informazioni fratello
                    BrotherHeaderView(brother: authService.currentBrother!)
                        .padding(.bottom, 10)
                    
                    // Barra di navigazione
                    NavigationTabBar(selectedTab: $selectedTab)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Contenuto principale
                    ScrollView {
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case 0:
                                HomeContentView(brother: authService.currentBrother!)
                            case 1:
                                TornateListView()
                            case 2:
                                PresenzeView(brother: authService.currentBrother!)
                            case 3:
                                TavoleView(brother: authService.currentBrother!)
                            case 4:
                                BibliotecaView()
                            case 5:
                                MieiPrestitiView()
                            case 6:
                                ChatView()
                            case 7:
                                NotificheView()
                            case 8:
                                if authService.currentBrother!.isAdmin {
                                    AdministrationView()
                                }
                            default:
                                HomeContentView(brother: authService.currentBrother!)
                            }
                        }
                        .padding()
                    }
                }
            }
            // macOS-compatible: Use .toolbar(.hidden) instead of .navigationBarHidden (iOS-only)
            // On macOS, toolbar visibility is controlled differently
            #if os(iOS)
            .navigationBarHidden(true)
            #else
            .toolbar(.hidden, for: .navigationBar)
            #endif
        }
    }
}

struct BrotherHeaderView: View {
    let brother: Brother
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(brother.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppTheme.masonicBlue)
                    
                    Text(brother.degree.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    if brother.role != .none {
                        Text(brother.role.rawValue)
                            .font(.caption)
                            .foregroundColor(AppTheme.masonicGold)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.masonicGold.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 40))
                    .foregroundColor(AppTheme.masonicBlue)
            }
            .padding()
            .background(AppTheme.white)
            .cornerRadius(12)
            .shadow(color: AppTheme.cardShadow, radius: 4, x: 0, y: 2)
            .padding(.horizontal)
        }
        .padding(.top, 10)
    }
}

struct NavigationTabBar: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var authService: AuthenticationService
    @EnvironmentObject var notificationService: NotificationService
    @EnvironmentObject var chatService: ChatService
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                TabButton(title: "Home", icon: "house.fill", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                
                TabButton(title: "Tornate", icon: "calendar", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                
                TabButton(title: "Presenze", icon: "chart.bar.fill", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                
                TabButton(title: "Tavole", icon: "doc.text.fill", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
                
                TabButton(title: "Biblioteca", icon: "books.vertical.fill", isSelected: selectedTab == 4) {
                    selectedTab = 4
                }
                
                TabButton(title: "Prestiti", icon: "book.closed", isSelected: selectedTab == 5) {
                    selectedTab = 5
                }
                
                TabButtonWithBadge(
                    title: "Chat",
                    icon: "message.fill",
                    isSelected: selectedTab == 6,
                    badge: authService.currentBrother != nil ? chatService.getUnreadCount(for: authService.currentBrother!.id) : 0
                ) {
                    selectedTab = 6
                }
                
                TabButtonWithBadge(
                    title: "Notifiche",
                    icon: "bell.fill",
                    isSelected: selectedTab == 7,
                    badge: notificationService.nonLette
                ) {
                    selectedTab = 7
                }
                
                if authService.currentBrother?.isAdmin == true {
                    TabButton(title: "Admin", icon: "gear", isSelected: selectedTab == 8) {
                        selectedTab = 8
                    }
                }
                
                Button(action: {
                    authService.logout()
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Esci")
                    }
                    .font(.footnote)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? AppTheme.white : AppTheme.masonicBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.masonicBlue : AppTheme.white)
            .cornerRadius(8)
            .shadow(color: AppTheme.cardShadow, radius: 2, x: 0, y: 1)
        }
    }
}

struct TabButtonWithBadge: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let badge: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
                
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.error)
                        .cornerRadius(8)
                }
            }
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(isSelected ? AppTheme.white : AppTheme.masonicBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AppTheme.masonicBlue : AppTheme.white)
            .cornerRadius(8)
            .shadow(color: AppTheme.cardShadow, radius: 2, x: 0, y: 1)
        }
    }
}

#Preview {
    DashboardView()
}
