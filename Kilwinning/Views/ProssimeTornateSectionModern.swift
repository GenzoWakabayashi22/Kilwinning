import SwiftUI

struct ProssimeTornateSectionModern: View {
    let brother: Brother
    @EnvironmentObject var dataService: DataService
    
    var upcomingTornate: [Tornata] {
        dataService.tornate
            .filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Prossime Tornate")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.gray)
            }
            
            if upcomingTornate.isEmpty {
                Text("Nessuna tornata in programma")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(upcomingTornate) { tornata in
                    NavigationLink(destination: TornataDetailView(tornata: tornata, brother: brother)) {
                        TornataCardModern(tornata: tornata)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}

#Preview {
    ProssimeTornateSectionModern(brother: Brother(
        firstName: "Paolo Giulio",
        lastName: "Gazzano",
        email: "demo@kilwinning.it",
        degree: .maestro,
        role: .venerabileMaestro,
        isAdmin: true
    ))
}
