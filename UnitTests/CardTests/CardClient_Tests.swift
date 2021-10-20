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
    
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    var cardClient: CardClient!
    
    // MARK: - Test lifecycle
    
    override func setUp() {
        super.setUp()
        
        mockURLSession = MockURLSession()
        mockURLSession.cannedError = nil
        mockURLSession.cannedURLResponse = nil
        mockURLSession.cannedJSONData = nil
        
        apiClient = APIClient(urlSession: mockURLSession, environment: .sandbox)
        cardClient = CardClient(config: config, apiClient: apiClient)
    }
    
    // MARK: - approveOrder() tests

    func testApproveOrder_withValidJSONRequest_returnsOrderData() {
        let expect = expectation(description: "Callback invoked.")

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
        mockURLSession.cannedJSONData = jsonResponse

        cardClient.approveOrder(orderID: "", card: card) { result in
            switch result {
            case .success(let cardResult):
                XCTAssertEqual(cardResult.orderID, "testOrderID")
                XCTAssertEqual(cardResult.status, .approved)
                XCTAssertEqual(cardResult.brand, "VISA")
                XCTAssertEqual(cardResult.lastFourDigits, "7321")
                XCTAssertEqual(cardResult.type, "CREDIT")
            case .failure(_):
                XCTFail()
            }
            
            expect.fulfill()
        }

        waitForExpectations(timeout: 1)
    }

    func testApproveOrder_withInvalidJSONResponse_returnsParseError() throws {
        let expect = expectation(description: "Callback invoked.")

        let jsonResponse = """

        {
            "some_unexpected_response": "something"
        }
        """

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = jsonResponse

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
