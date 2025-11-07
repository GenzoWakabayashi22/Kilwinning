import XCTest
@testable import KilwinningApp

final class BrotherTests: XCTestCase {
    
    func testBrotherFullName() {
        let brother = Brother(
            firstName: "Paolo",
            lastName: "Rossi",
            email: "paolo@test.it",
            degree: .maestro
        )
        
        XCTAssertEqual(brother.fullName, "Paolo Rossi")
    }
    
    func testBrotherDisplayRoleWithRole() {
        let brother = Brother(
            firstName: "Paolo",
            lastName: "Rossi",
            email: "paolo@test.it",
            degree: .maestro,
            role: .venerabileMaestro
        )
        
        XCTAssertEqual(brother.displayRole, "Ven.mo Maestro – Paolo Rossi")
    }
    
    func testBrotherDisplayRoleWithoutRole() {
        let brother = Brother(
            firstName: "Paolo",
            lastName: "Rossi",
            email: "paolo@test.it",
            degree: .apprendista
        )
        
        XCTAssertEqual(brother.displayRole, "Apprendista – Paolo Rossi")
    }
    
    func testMasonicDegreeValues() {
        XCTAssertEqual(MasonicDegree.apprendista.rawValue, "Apprendista")
        XCTAssertEqual(MasonicDegree.compagno.rawValue, "Compagno")
        XCTAssertEqual(MasonicDegree.maestro.rawValue, "Maestro")
    }
}
