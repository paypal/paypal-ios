import XCTest
@testable import PaymentsCore
@testable import Card

class APIClientTests: XCTestCase {

    lazy var apiClient: APIClient = {
        APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
    }()

    func testAccessTokenMockRequest_Success() {
        let expect = expectation(description: "Get mock response for access token request")

        URLProtocolMock.requestResponses.append(MockAccessTokenRequestResponse(success: true))

        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, _ in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, "TestToken")
            case .failure(let error):
                XCTFail("Wrong mock response with error: \(error)")
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testAccessTokenMockRequest_Failure() {
        let expect = expectation(description: "Get mock response for access token request")

        URLProtocolMock.requestResponses.append(MockAccessTokenRequestResponse(success: false))

        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, _ in
            switch result {
            case .success:
                XCTFail("Should not be able to successfully decode a result")
            case .failure(let error):
                XCTAssertNotNil(error)
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    // TODO: Unit tests
    // - Write mock response (success + error) + tests
    // - Write CardExpiry tests (encode to expected value)
    // - Test ConfirmPaymentSourceRequest.path => pass in orderID => correct path
}
