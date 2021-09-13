import XCTest
@testable import PaymentsCore

class APIClientTests: XCTestCase {
    
    lazy var apiClient: APIClient = {
        APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
    }()

    func testAccessTokenMockRequestSuccess() {
        let expect = expectation(description: "Get mock response for access token request")

        URLProtocolMock.requestResponses.append(MockAccessTokenRequestResponse())
        
        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { (result: Result<AccessTokenRespose, Error>) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.access_token, "TestToken")
            case .failure(let error):
                XCTFail("Wrong mock response with error: \(error)")
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}

// TODO:
// - Create more mock (also test failure response)
// - Move mockTokenRequestresponse => separate folder for mocks
