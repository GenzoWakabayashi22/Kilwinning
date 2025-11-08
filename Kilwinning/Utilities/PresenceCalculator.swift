import Foundation

/// Utility class for calculating presence statistics and consecutive presences
class PresenceCalculator {

    /// Calculate consecutive presences starting from most recent tornata
    /// IMPORTANT: Starts counting from most recent and stops at first absence
    static func calculateConsecutive(presences: [Presence], tornate: [Tornata]) -> Int {
        // Create a dictionary for quick lookup of presences by tornata ID
        let presenceDict = Dictionary(uniqueKeysWithValues: presences.map { ($0.tornataId, $0) })

        // Filter and sort tornate by date (most recent first)
        let sortedTornate = tornate
            .sorted { $0.data > $1.data }

        var consecutiveCount = 0

        // Count consecutive presences from most recent
        for tornata in sortedTornate {
            if let presence = presenceDict[tornata.id], presence.presente {
                consecutiveCount += 1
            } else {
                // Stop at first absence
                break
            }
        }

        return consecutiveCount
    }

    /// Filter tornate based on fratello's data iniziazione
    /// IMPORTANT: Only tornate >= dataIniziazione are valid for the fratello
    static func filterTornateByInitiation(tornate: [Tornata], dataIniziazione: Date?) -> [Tornata] {
        guard let initiationDate = dataIniziazione else {
            // If no initiation date, return all tornate
            return tornate
        }

        return tornate.filter { tornata in
            tornata.data >= initiationDate
        }
    }

    /// Calculate full statistics for a fratello
    static func calculateStatistics(
        fratelloId: Int,
        presences: [Presence],
        tornate: [Tornata],
        dataIniziazione: Date?
    ) -> PresenceStatistics {
        // Filter tornate by initiation date
        let validTornate = filterTornateByInitiation(tornate: tornate, dataIniziazione: dataIniziazione)

        // Count presences and absences
        let presenceCount = presences.filter { $0.presente }.count
        let absenceCount = validTornate.count - presenceCount

        // Calculate consecutive presences
        let consecutive = calculateConsecutive(presences: presences, tornate: validTornate)

        // Calculate personal record (would need historical data - for now same as consecutive)
        let personalRecord = consecutive

        // Calculate percentage
        let percentage = validTornate.count > 0 ? Int((Double(presenceCount) / Double(validTornate.count)) * 100) : 0

        return PresenceStatistics(
            totalTornate: validTornate.count,
            presences: presenceCount,
            absences: absenceCount,
            presenzeConsecutive: consecutive,
            personalRecord: personalRecord
        )
    }

    /// Filter presences by year
    static func filterPresencesByYear(presences: [Presence], tornate: [Tornata], anno: String) -> ([Presence], [Tornata]) {
        if anno == "tutti" {
            return (presences, tornate)
        }

        guard let year = Int(anno) else {
            return (presences, tornate)
        }

        let calendar = Calendar.current

        // Filter tornate by year
        let filteredTornate = tornate.filter { tornata in
            let components = calendar.dateComponents([.year], from: tornata.data)
            return components.year == year
        }

        // Get IDs of filtered tornate
        let tornataIds = Set(filteredTornate.map { $0.id })

        // Filter presences to match filtered tornate
        let filteredPresences = presences.filter { tornataIds.contains($0.tornataId) }

        return (filteredPresences, filteredTornate)
    }

    /// Get available years from tornate
    static func getAvailableYears(tornate: [Tornata]) -> [String] {
        let calendar = Calendar.current
        let years = Set(tornate.compactMap { tornata -> Int? in
            calendar.dateComponents([.year], from: tornata.data).year
        })

        return years.sorted(by: >).map { String($0) }
    }

    /// Check if fratello is admin based on name
    /// As specified in requirements: Paolo Giulio Gazzano and Emiliano Menicucci
    static func isAdmin(nome: String) -> Bool {
        let adminNames = ["Paolo Giulio Gazzano", "Emiliano Menicucci"]
        return adminNames.contains(nome)
    }

    /// Get degree icon/emoji
    static func getDegreeIcon(grado: String) -> String {
        switch grado.lowercased() {
        case "maestro", "maestri":
            return "🔶"
        case "compagno", "compagni":
            return "🔷"
        case "apprendista", "apprendisti":
            return "🔹"
        default:
            return "◆"
        }
    }

    /// Format presence percentage with color
    static func getPercentageColor(percentuale: Int) -> String {
        switch percentuale {
        case 90...100:
            return "green"
        case 70..<90:
            return "orange"
        default:
            return "red"
        }
    }

    /// Get stato badge color
    static func getStatoBadgeColor(stato: String) -> String {
        switch stato.lowercased() {
        case "programmata":
            return "blue"
        case "completata":
            return "green"
        case "annullata":
            return "red"
        default:
            return "gray"
        }
    }
}
