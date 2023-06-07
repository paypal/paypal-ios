import XCTest
@testable import TestShared
@testable import CorePayments

class HTTPResponseParser_Tests: XCTestCase {
    
    // MARK: - Helper Properties

    let sut = HTTPResponseParser()

    // MARK: - parse()
    
    func testParse_whenNoBody_returnsError() {
        let mockHTTPResponse = HTTPResponse(status: 200, body: nil)
        
        do {
            _ = try sut.parse(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.localizedDescription, "An error occured due to missing HTTP response data. Contact developer.paypal.com/support.")
            XCTAssertEqual(error.domain, APIClientError.domain)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
    
    func testParse_whenSuccessStatusCodeWithValidBody_returnsDecodable() {
        let jsonResponse = #"{ "fake_param": "fake-response" }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        do {
            let response = try sut.parse(mockHTTPResponse, as: FakeResponse.self)
            XCTAssertEqual(response.fakeParam, "fake-response")
        } catch {
            XCTFail("Expected parse() to succeed")
        }
    }
    
    func testParse_whenSuccessStatusCodeWithDecodingError_bubblesDecodingErrorMessage() {
        let jsonResponse = #"{ "incorrect_body": "borked-response" }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        let sut = HTTPResponseParser(decoder: FailingJSONDecoder())
        
        do {
            _ = try sut.parse(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Stub message from JSONDecoder.")
        }
    }
    
    func testParse_whenBadStatusCodeWithErrorBody_returnsReadableError() {
        let jsonResponse = """
        {
            "name": "fake-error-name",
            "message": "fake-message"
        }
        """
        let mockHTTPResponse = HTTPResponse(status: 500, body: jsonResponse.data(using: .utf8)!)
        
        do {
            _ = try sut.parse(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch let error as CoreSDKError {
            XCTAssertEqual(error.localizedDescription, "fake-error-name: fake-message")
            XCTAssertEqual(error.domain, APIClientError.domain)
        } catch {
            XCTFail("Unexpected error type")
        }
    }
}
