import Foundation
import Combine

/// Servizio per la gestione dei dati
@MainActor
class DataService: ObservableObject {
    @Published var tornate: [Tornata] = []
    @Published var presences: [Presence] = []
    @Published var tavole: [Tavola] = []
    @Published var brothers: [Brother] = []
    
    static let shared = DataService()
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Tornate
    
    func fetchTornate() async {
        // TODO: Implementare chiamata a backend o CloudKit
        // Per ora usiamo dati mock
    }
    
    func createTornata(_ tornata: Tornata) async {
        tornate.append(tornata)
        tornate.sort { $0.date > $1.date }
    }
    
    func updateTornata(_ tornata: Tornata) async {
        if let index = tornate.firstIndex(where: { $0.id == tornata.id }) {
            tornate[index] = tornata
        }
    }
    
    func deleteTornata(_ tornata: Tornata) async {
        tornate.removeAll { $0.id == tornata.id }
    }
    
    // MARK: - Presenze
    
    func updatePresence(brotherId: UUID, tornataId: UUID, status: PresenceStatus) async {
        if let index = presences.firstIndex(where: { $0.brotherId == brotherId && $0.tornataId == tornataId }) {
            var presence = presences[index]
            presence.status = status
            presence.confirmedAt = Date()
            presences[index] = presence
        } else {
            let presence = Presence(brotherId: brotherId, tornataId: tornataId, status: status, confirmedAt: Date())
            presences.append(presence)
        }
    }
    
    func getPresenceStatus(brotherId: UUID, tornataId: UUID) -> PresenceStatus {
        presences.first { $0.brotherId == brotherId && $0.tornataId == tornataId }?.status ?? .nonConfermato
    }
    
    func calculateStatistics(for brotherId: UUID, year: Int) -> PresenceStatistics {
        let calendar = Calendar.current
        let yearTornate = tornate.filter { calendar.component(.year, from: $0.date) == year }
        
        let brotherPresences = presences.filter { $0.brotherId == brotherId }
        let yearPresences = brotherPresences.filter { presence in
            yearTornate.contains { $0.id == presence.tornataId }
        }
        
        let presentCount = yearPresences.filter { $0.status == .presente }.count
        let absentCount = yearPresences.filter { $0.status == .assente }.count
        
        // Calcola presenze consecutive
        let consecutive = calculateConsecutivePresences(for: brotherId)
        
        return PresenceStatistics(
            totalTornate: yearTornate.count,
            presences: presentCount,
            absences: absentCount,
            consecutivePresences: consecutive,
            personalRecord: consecutive,
            attendanceRate: 0
        )
    }
    
    private func calculateConsecutivePresences(for brotherId: UUID) -> Int {
        let sortedTornate = tornate.sorted { $0.date < $1.date }
        var consecutive = 0
        var maxConsecutive = 0
        
        for tornata in sortedTornate {
            let status = getPresenceStatus(brotherId: brotherId, tornataId: tornata.id)
            if status == .presente {
                consecutive += 1
                maxConsecutive = max(maxConsecutive, consecutive)
            } else if status == .assente {
                consecutive = 0
            }
        }
        
        return maxConsecutive
    }
    
    // MARK: - Tavole
    
    func fetchTavole(for brotherId: UUID) -> [Tavola] {
        tavole.filter { $0.brotherId == brotherId }
    }
    
    func createTavola(_ tavola: Tavola) async {
        tavole.append(tavola)
    }
    
    func updateTavola(_ tavola: Tavola) async {
        if let index = tavole.firstIndex(where: { $0.id == tavola.id }) {
            tavole[index] = tavola
        }
    }
    
    // MARK: - Brothers
    
    func fetchBrothers() async {
        // TODO: Implementare chiamata a backend
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Tornate di esempio per il 2025
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = 2025
        dateComponents.month = 11
        dateComponents.day = 25
        dateComponents.hour = 19
        dateComponents.minute = 30
        
        let tornata1Id = UUID()
        if let date1 = calendar.date(from: dateComponents) {
            tornate.append(Tornata(
                id: tornata1Id,
                title: "Il sentiero della saggezza",
                date: date1,
                type: .ordinaria,
                location: .tofa,
                introducedBy: "Fr. Marco Rossi"
            ))
        }
        
        dateComponents.month = 12
        dateComponents.day = 10
        let tornata2Id = UUID()
        if let date2 = calendar.date(from: dateComponents) {
            tornate.append(Tornata(
                id: tornata2Id,
                title: "La ricerca della verità",
                date: date2,
                type: .ordinaria,
                location: .tofa,
                introducedBy: "Fr. Giuseppe Bianchi"
            ))
        }
        
        dateComponents.month = 12
        dateComponents.day = 22
        if let date3 = calendar.date(from: dateComponents) {
            tornate.append(Tornata(
                title: "Cerimonia di Passaggio di Grado",
                date: date3,
                type: .cerimonia,
                location: .tofa,
                introducedBy: "Ven.mo Maestro"
            ))
        }
        
        // Aggiungi tavole di esempio con PDF e collegamento alle tornate
        // Usa l'ID del fratello demo se disponibile
        let demoFratelloId = UUID() // In produzione questo sarà l'ID del fratello loggato
        
        tavole.append(Tavola(
            brotherId: demoFratelloId,
            title: "Il Simbolismo della Squadra e del Compasso",
            presentationDate: dateComponents.month == 12 && dateComponents.day == 10 ? 
                calendar.date(from: dateComponents) : Date(),
            status: .completata,
            content: "Approfondimento sul significato simbolico degli strumenti del Libero Muratore.",
            pdfURL: "https://example.com/tavole/simbolismo_squadra_compasso.pdf",
            idTornata: tornata1Id
        ))
        
        tavole.append(Tavola(
            brotherId: demoFratelloId,
            title: "La Ricerca Interiore nel Percorso Massonico",
            presentationDate: nil,
            status: .programmato,
            content: "Studio sul cammino di perfezionamento personale.",
            pdfURL: "https://example.com/tavole/ricerca_interiore.pdf",
            idTornata: tornata2Id
        ))
    }
}
