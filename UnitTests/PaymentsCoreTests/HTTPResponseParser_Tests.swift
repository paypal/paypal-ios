import XCTest
@testable import TestShared
@testable import CorePayments

class HTTPResponseParser_Tests: XCTestCase {
    
    // MARK: - Helper Properties

    let sut = HTTPResponseParser()

    // MARK: - parseREST()
    
    func testParseREST_whenNoBody_returnsError() {
        let mockHTTPResponse = HTTPResponse(status: 200, body: nil)
        
        do {
            _ = try sut.parseREST(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.localizedDescription, "An error occured due to missing HTTP response data. Contact developer.paypal.com/support.")
            XCTAssertEqual(error.domain, NetworkingError.domain)
        }
    }
    
    func testParseREST_whenSuccessStatusCodeWithValidBody_returnsDecodable() {
        let jsonResponse = #"{ "fake_param": "fake-response" }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        do {
            let response = try sut.parseREST(mockHTTPResponse, as: FakeResponse.self)
            XCTAssertEqual(response.fakeParam, "fake-response")
        } catch {
            XCTFail("Expected parse() to succeed")
        }
    }
    
    func testParseREST_whenSuccessStatusCodeWithDecodingError_bubblesDecodingErrorMessage() {
        let jsonResponse = #"{ "incorrect_body": "borked-response" }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        let sut = HTTPResponseParser(decoder: FailingJSONDecoder())
        
        do {
            _ = try sut.parseREST(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Stub message from JSONDecoder.")
        }
    }
    
    func testParseREST_whenBadStatusCodeWithErrorBody_returnsReadableError() {
        let jsonResponse = """
        {
            "name": "fake-error-name",
            "message": "fake-message"
        }
        """
        let mockHTTPResponse = HTTPResponse(status: 500, body: jsonResponse.data(using: .utf8)!)
        
        do {
            _ = try sut.parseREST(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.localizedDescription, "fake-error-name: fake-message")
            XCTAssertEqual(error.domain, NetworkingError.domain)
        }
    }
    
    // MARK: - parseGraphQL()
    
    func testParseGraphQL_whenNoBody_returnsError() {
        let mockHTTPResponse = HTTPResponse(status: 200, body: nil)
        
        do {
            _ = try sut.parseGraphQL(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.localizedDescription, "An error occured due to missing HTTP response data. Contact developer.paypal.com/support.")
            XCTAssertEqual(error.domain, NetworkingError.domain)
        }
    }
    
    func testParseGraphQL_whenSuccessStatusCodeWithValidBody_returnsDecodable() {
        let jsonResponse = #"{ "data": { "fake_param": "fake-response" } }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        do {
            let response = try sut.parseGraphQL(mockHTTPResponse, as: FakeResponse.self)
            XCTAssertEqual(response.fakeParam, "fake-response")
        } catch {
            XCTFail("Expected parse() to succeed")
        }
    }
    
    func testParseGraphQL_whenSuccessStatusCodeWithMissingDataField_returnsError() {
        let jsonResponse = #"{ "fake_param": "fake-response" }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        do {
            _ = try sut.parseGraphQL(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.localizedDescription, "An error occured due to missing `data` key in GraphQL query response. Contact developer.paypal.com/support.")
            XCTAssertEqual(error.domain, NetworkingError.domain)
        }
    }
    
    func testParseGraphQL_whenSuccessStatusCodeWithDecodingError_bubblesDecodingErrorMessage() {
        let jsonResponse = #"{ "incorrect_body": "borked-response" }"#
        let mockHTTPResponse = HTTPResponse(status: 203, body: jsonResponse.data(using: .utf8)!)
        
        let sut = HTTPResponseParser(decoder: FailingJSONDecoder())
        
        do {
            _ = try sut.parseGraphQL(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            XCTAssertEqual(error.localizedDescription, "Stub message from JSONDecoder.")
        }
    }
    
    func testParseGraphQL_whenBadStatusCodeWithErrorBody_returnsReadableError() {
        let jsonResponse = """
        {
            "error": "fake-error-description",
            "correlation_id": "fake-correlation-id"
        }
        """
        let mockHTTPResponse = HTTPResponse(status: 500, body: jsonResponse.data(using: .utf8)!)
        
        do {
            _ = try sut.parseGraphQL(mockHTTPResponse, as: FakeResponse.self)
            XCTFail("Expected parse() to throw")
        } catch {
            let error = error as! CoreSDKError
            XCTAssertEqual(error.localizedDescription, "fake-error-description")
            XCTAssertEqual(error.domain, NetworkingError.domain)
        }
    }
}
