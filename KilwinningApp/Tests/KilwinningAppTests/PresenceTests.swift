import XCTest
@testable import KilwinningApp

final class PresenceTests: XCTestCase {
    
    func testPresenceStatusValues() {
        XCTAssertEqual(PresenceStatus.presente.rawValue, "Presente")
        XCTAssertEqual(PresenceStatus.assente.rawValue, "Assente")
        XCTAssertEqual(PresenceStatus.nonConfermato.rawValue, "Non Confermato")
    }
    
    func testPresenceStatisticsCalculation() {
        let stats = PresenceStatistics(
            totalTornate: 20,
            presences: 18,
            absences: 2,
            consecutivePresences: 10,
            personalRecord: 15
        )
        
        XCTAssertEqual(stats.totalTornate, 20)
        XCTAssertEqual(stats.presences, 18)
        XCTAssertEqual(stats.absences, 2)
        XCTAssertEqual(stats.attendanceRate, 0.9, accuracy: 0.01)
        XCTAssertEqual(stats.formattedAttendanceRate, "90%")
    }
    
    func testPresenceStatisticsZeroTornate() {
        let stats = PresenceStatistics(
            totalTornate: 0,
            presences: 0,
            absences: 0,
            consecutivePresences: 0,
            personalRecord: 0
        )
        
        XCTAssertEqual(stats.attendanceRate, 0.0)
        XCTAssertEqual(stats.formattedAttendanceRate, "0%")
    }
}
