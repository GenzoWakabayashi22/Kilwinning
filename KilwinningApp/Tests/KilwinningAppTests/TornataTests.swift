import XCTest
@testable import KilwinningApp

final class TornataTests: XCTestCase {
    
    func testTornataCreation() {
        let date = Date()
        let tornata = Tornata(
            title: "Test Tornata",
            date: date,
            type: .ordinaria,
            location: .tofa,
            introducedBy: "Fr. Test"
        )
        
        XCTAssertEqual(tornata.title, "Test Tornata")
        XCTAssertEqual(tornata.type, .ordinaria)
        XCTAssertEqual(tornata.location, .tofa)
        XCTAssertEqual(tornata.introducedBy, "Fr. Test")
        XCTAssertFalse(tornata.hasDinner)
    }
    
    func testTornataLocationIsHome() {
        XCTAssertTrue(TornataLocation.tofa.isHome)
        XCTAssertFalse(TornataLocation.visita.isHome)
    }
    
    func testTornataType() {
        XCTAssertEqual(TornataType.ordinaria.rawValue, "Ordinaria")
        XCTAssertEqual(TornataType.cerimonia.rawValue, "Cerimonia")
    }
}
