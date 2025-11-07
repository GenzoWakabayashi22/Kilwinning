import Foundation
import Combine
#if canImport(UserNotifications)
import UserNotifications
#endif

/// Servizio per la gestione delle notifiche
@MainActor
class NotificationService: ObservableObject {
    @Published var notifiche: [Notification] = []
    @Published var nonLette: Int = 0
    
    static let shared = NotificationService()
    
    private init() {
        loadMockData()
        calculateNonLette()
    }
    
    // MARK: - Setup
    
    /// Richiedi permessi per le notifiche
    func richediPermessi() async -> Bool {
        #if canImport(UserNotifications)
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Errore richiesta permessi notifiche: \(error)")
            return false
        }
        #else
        return false
        #endif
    }
    
    // MARK: - Fetch Methods
    
    /// Ottieni tutte le notifiche
    func fetchNotifiche() async {
        // TODO: Implementare chiamata reale a backend
        try? await Task.sleep(nanoseconds: 500_000_000)
        calculateNonLette()
    }
    
    /// Ottieni notifiche non lette
    func fetchNotificheNonLette() -> [Notification] {
        return notifiche.filter { !$0.letto }
    }
    
    // MARK: - CRUD Operations
    
    /// Aggiungi una nuova notifica
    func addNotifica(_ notifica: Notification) async {
        // TODO: Implementare chiamata reale a backend
        notifiche.insert(notifica, at: 0)
        calculateNonLette()
        
        // Mostra notifica locale se i permessi sono stati concessi
        await mostraNotificaLocale(notifica)
    }
    
    /// Segna una notifica come letta
    func segnaComeLetta(_ notificaId: Int) async {
        // TODO: Implementare chiamata reale a backend
        if let index = notifiche.firstIndex(where: { $0.id == notificaId }) {
            notifiche[index].letto = true
        }
        calculateNonLette()
    }
    
    /// Segna tutte le notifiche come lette
    func segnaTutteComeLette() async {
        // TODO: Implementare chiamata reale a backend
        for i in notifiche.indices {
            notifiche[i].letto = true
        }
        calculateNonLette()
    }
    
    /// Elimina una notifica
    func eliminaNotifica(_ notificaId: Int) async {
        // TODO: Implementare chiamata reale a backend
        notifiche.removeAll { $0.id == notificaId }
        calculateNonLette()
    }
    
    // MARK: - Notification Creation Helpers
    
    /// Crea notifica per nuova tornata
    func notificaNuovaTornata(tornata: String, data: String) async {
        let newId = (notifiche.map { $0.id }.max() ?? 0) + 1
        let notifica = Notification(
            id: newId,
            tipo: .nuovaTornata,
            titolo: "Nuova Tornata Programmata",
            messaggio: "\(tornata) - \(data)",
            dataCreazione: Date(),
            letto: false
        )
        await addNotifica(notifica)
    }
    
    /// Crea notifica per nuova discussione audio
    func notificaNuovaDiscussione(titolo: String, fratello: String) async {
        let newId = (notifiche.map { $0.id }.max() ?? 0) + 1
        let notifica = Notification(
            id: newId,
            tipo: .nuovaDiscussione,
            titolo: "Nuova Discussione Audio",
            messaggio: "\(titolo) di Fr. \(fratello)",
            dataCreazione: Date(),
            letto: false
        )
        await addNotifica(notifica)
    }
    
    /// Crea notifica per nuova tavola
    func notificaNuovaTavola(titolo: String, autore: String) async {
        let newId = (notifiche.map { $0.id }.max() ?? 0) + 1
        let notifica = Notification(
            id: newId,
            tipo: .nuovaTavola,
            titolo: "Nuova Tavola Pubblicata",
            messaggio: "\(titolo) di Fr. \(autore)",
            dataCreazione: Date(),
            letto: false
        )
        await addNotifica(notifica)
    }
    
    /// Crea notifica per nuovo libro
    func notificaNuovoLibro(titolo: String, autore: String) async {
        let newId = (notifiche.map { $0.id }.max() ?? 0) + 1
        let notifica = Notification(
            id: newId,
            tipo: .nuovoLibro,
            titolo: "Nuovo Libro in Biblioteca",
            messaggio: "\(titolo) di \(autore)",
            dataCreazione: Date(),
            letto: false
        )
        await addNotifica(notifica)
    }
    
    /// Crea notifica per libro restituito
    func notificaLibroRestituito(titolo: String) async {
        let newId = (notifiche.map { $0.id }.max() ?? 0) + 1
        let notifica = Notification(
            id: newId,
            tipo: .libroRestituito,
            titolo: "Libro Restituito",
            messaggio: "\(titolo) è ora disponibile",
            dataCreazione: Date(),
            letto: false
        )
        await addNotifica(notifica)
    }
    
    /// Crea notifica per nuovo messaggio
    func notificaNuovoMessaggio(chat: String, anteprima: String) async {
        let newId = (notifiche.map { $0.id }.max() ?? 0) + 1
        let notifica = Notification(
            id: newId,
            tipo: .nuovoMessaggio,
            titolo: "Nuovo Messaggio in \(chat)",
            messaggio: anteprima,
            dataCreazione: Date(),
            letto: false
        )
        await addNotifica(notifica)
    }
    
    // MARK: - Local Notifications
    
    private func mostraNotificaLocale(_ notifica: Notification) async {
        #if canImport(UserNotifications)
        let content = UNMutableNotificationContent()
        content.title = notifica.titolo
        content.body = notifica.messaggio
        content.sound = .default
        content.badge = NSNumber(value: nonLette)
        
        // Trigger immediato
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "notifica-\(notifica.id)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Errore mostrando notifica locale: \(error)")
        }
        #endif
    }
    
    // MARK: - Private Helpers
    
    private func calculateNonLette() {
        nonLette = notifiche.filter { !$0.letto }.count
    }
    
    // MARK: - Mock Data
    
    private func loadMockData() {
        // Notifiche di esempio
        notifiche = [
            Notification(
                id: 1,
                tipo: .nuovaTornata,
                titolo: "Nuova Tornata Programmata",
                messaggio: "Il sentiero della saggezza - 25 novembre 2025",
                dataCreazione: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                letto: false
            ),
            Notification(
                id: 2,
                tipo: .nuovoLibro,
                titolo: "Nuovo Libro in Biblioteca",
                messaggio: "Il Simbolismo Massonico di Jules Boucher",
                dataCreazione: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
                letto: true
            )
        ]
    }
}
