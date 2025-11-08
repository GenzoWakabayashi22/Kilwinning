import SwiftUI

struct TornateListView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var authService: AuthenticationService
    @State private var searchText = ""
    
    var filteredTornate: [Tornata] {
        if searchText.isEmpty {
            return dataService.tornate.sorted { $0.date > $1.date }
        }
        return dataService.tornate
            .filter { $0.title.localizedCaseInsensitiveContains(searchText) }
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            AppTheme.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Tornate")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(filteredTornate.count) tornate")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Cerca", text: $searchText)
                        .foregroundColor(.white)
                }
                .padding()
                .background(AppTheme.darkCardBackground)
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Lista Tornate
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredTornate) { tornata in
                            if let brother = authService.currentBrother {
                                NavigationLink(destination: TornataDetailView(tornata: tornata, brother: brother)) {
                                    TornataCardModern(tornata: tornata)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }
            }
        }
#if os(iOS)
.navigationBarHidden(true)
#elseif os(macOS)
.toolbar(.hidden, for: .automatic)
#endif
    }
}

struct TornataCardModern: View {
    let tornata: Tornata
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        HStack(spacing: 15) {
            // Immagine copertina (rettangolare)
            AsyncImage(url: URL(string: tornata.coverImageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    placeholderImage
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            .clipped()
            
            // Informazioni tornata
            VStack(alignment: .leading, spacing: 8) {
                Text(tornata.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.masonicGold)
                    
                    Text(tornata.formattedTime)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: tornata.location.isHome ? "house.fill" : "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppTheme.masonicGold)
                    
                    Text(tornata.location.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Badge tipo tornata
                Text(tornata.type.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tornata.type == .cerimonia ? AppTheme.masonicGold : AppTheme.masonicBlue)
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding()
        .background(AppTheme.darkCardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var placeholderImage: some View {
        ZStack {
            AppTheme.masonicBlue
            
            Image(systemName: "building.columns.fill")
                .font(.system(size: 30))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

#Preview {
    TornateListView()
}
