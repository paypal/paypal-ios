import XCTest
@testable import PaymentsCore
@testable import Card
@testable import TestShared

final class CardClient_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )
    let config = CoreConfig(clientID: "", environment: .sandbox)
    
    var mockURLSession: URLSessionMock!
    var apiClient: APIClient!
    var cardClient: CardClient!
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        mockURLSession = URLSessionMock()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedData = nil
        
        apiClient = APIClient(urlSession: mockURLSession, environment: .sandbox)
        cardClient = CardClient(config: config, apiClient: apiClient)
    }
    
    // MARK: - approveOrder() tests
    
    func testApproveOrder_withInvalidPaymentSourceRequest_returnsEncodingError() {
        let expect = expectation(description: "Get success mock response")

        let jsonResponse = """
        {
            "id": "testOrderID",
            "status": "APPROVED",
            "payment_source": {
                "card": {
                    "last_digits": "7321",
                    "brand": "VISA",
                    "type": "CREDIT"
                }
            }
        }
        """
        
        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedData = jsonResponse.data(using: String.Encoding.utf8)!

        cardClient.approveOrder(orderID: "", card: card) { result in
            guard case .success(let orderData) = result else {
                XCTFail("Expect success response")
                return
            }

            XCTAssertEqual(orderData.orderID, "testOrderID")
            XCTAssertEqual(orderData.status, .approved)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
        
    }

    func testApproveCardOrder_withInvalidFormatMockResponse_returnsParsingError() throws {
        let expect = expectation(description: "Get success mock response")

        let jsonResponse = """
        {
            "some_unexpected_response": "something"
        }
        """

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedData = jsonResponse.data(using: String.Encoding.utf8)!

        cardClient.approveOrder(orderID: "", card: card) { result in
            guard case .failure(NetworkingError.parsingError) = result else {
                XCTFail("Expect NetworkingError.parsingError for invalid response")
                return
            }

            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

}
