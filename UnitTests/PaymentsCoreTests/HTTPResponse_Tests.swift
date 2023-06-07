import XCTest
@testable import CorePayments

class HTTPResponse_Tests: XCTestCase {
    
    func testIsSuccessful_whenStatusBelow200_returnsFalse() {
        let sut = HTTPResponse(status: 199, body: nil)
        XCTAssertFalse(sut.isSuccessful)
    }
    
    func testIsSuccessful_whenStatusAboveOrEqualTo300_returnsFalse() {
        let sut = HTTPResponse(status: 300, body: nil)
        XCTAssertFalse(sut.isSuccessful)
        
        let sutB = HTTPResponse(status: 500, body: nil)
        XCTAssertFalse(sutB.isSuccessful)
    }
    
    func testIsSuccessful_whenStatusWithinRange_returnsTrue() {
        let sut = HTTPResponse(status: 200, body: nil)
        XCTAssertTrue(sut.isSuccessful)
    }
}
