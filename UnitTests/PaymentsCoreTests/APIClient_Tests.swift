import XCTest
@testable import PaymentsCore
@testable import TestShared

class APIClient_Tests: XCTestCase {

    // MARK: - Helper Properties
    let mockClientID = "mockClientId"
    let mockAccessToken = "mockAccessToken"

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let fakeRequest = FakeRequest()

    // swiftlint:disable implicitly_unwrapped_optional
    var config: CoreConfig!
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    // swiftlint:enable implicitly_unwrapped_optional

    // MARK: - Test lifecycle

    override func setUp() {
        super.setUp()
        config = CoreConfig(accessToken: mockAccessToken, environment: .sandbox)
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil

        apiClient = APIClient(urlSession: mockURLSession, coreConfig: config)
    }
    
    // MARK: - getClientID()

    func testGetClientID_successfullyReturnsData() async throws {
        mockURLSession.cannedJSONData = APIResponses.oauthTokenJson.rawValue
        mockURLSession.cannedURLResponse = successURLResponse

        let response = try await apiClient.getClientID()
        XCTAssertEqual(response, "sample_id")
    }
}
