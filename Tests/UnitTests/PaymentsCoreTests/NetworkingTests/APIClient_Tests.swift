import XCTest
@testable import PaymentsCore

class APIClient_Tests: XCTestCase {
    
    lazy var apiClient: APIClient = {
        APIClient(
            urlSession: URLSession(urlProtocol: URLProtocolMock.self),
            environment: .sandbox
        )
    }()

    func testFetch_withAccessTokenSuccessMockResponse_returnsValidAccessToken() {
        let expect = expectation(description: "Get mock response for access token request")

        URLProtocolMock.requestResponses.append(
            MockAccessTokenRequestResponse(responseString: MockAccessTokenRequestResponse.mockSuccessResponse, statusCode: 200)
        )
        
        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, correlationID in
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

    func testFetch_withAccessTokenFailureMockResponse_returnsNoURLRequest() {
        let expect = expectation(description: "Get mock response for access token request")

        URLProtocolMock.requestResponses.append(
            MockAccessTokenRequestResponse(responseString: MockAccessTokenRequestResponse.mockFailureResponse, statusCode: 404)
        )

        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, correlationID in
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

    func testFetch_withAccessTokenInvalidMockResponse_returnsDecodingError() {
        let expect = expectation(description: "Get mock response for access token request")

        URLProtocolMock.requestResponses.append(
            MockAccessTokenRequestResponse(responseString: MockAccessTokenRequestResponse.mockInvalidResponse, statusCode: 200)
        )

        apiClient.fetch(endpoint: AccessTokenRequest(clientID: "")) { result, correlationId in
            switch result {
            case .success:
                XCTFail("Should not succeed as the mock response has invalid format")
            case let .failure(error):
                guard case .decodingError(_) = error else {
                    XCTFail("Expect error to be NetworkingError.decodingError")
                    return
                }
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }
}
