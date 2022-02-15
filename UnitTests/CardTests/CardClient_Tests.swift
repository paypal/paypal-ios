import XCTest
@testable import PaymentsCore
@testable import Card
@testable import TestShared

class CardClient_Tests: XCTestCase {

    // MARK: - Helper Properties

    // swiftlint:disable:next force_unwrapping
    let successURLResponse = HTTPURLResponse(url: URL(string: "www.test.com")!, statusCode: 200, httpVersion: "https", headerFields: [:])
    let card = Card(
        number: "411111111111",
        expirationMonth: "01",
        expirationYear: "2021",
        securityCode: "123"
    )
    let config = CoreConfig(clientID: "", environment: .sandbox)

    // swiftlint:disable implicitly_unwrapped_optional
    var mockURLSession: MockURLSession!
    var apiClient: APIClient!
    var cardClient: CardClient!
    // swiftlint:enable implicitly_unwrapped_optional

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

    func testApproveOrder_withValidJSONRequest_returnsOrderData() async {
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

        let cardRequest = CardRequest(orderID: "", card: card)

        do {
            let cardResult = try await cardClient.approveOrder(request: cardRequest)
            XCTAssertEqual(cardResult.orderID, "testOrderID")
            XCTAssertEqual(cardResult.brand, "VISA")
            XCTAssertEqual(cardResult.lastFourDigits, "7321")
            XCTAssertEqual(cardResult.type, "CREDIT")
        } catch {
            XCTFail()
        }
    }

    func testApproveOrder_withInvalidJSONResponse_returnsParseError() async {
        let jsonResponse = """
        {
            "some_unexpected_response": "something"
        }
        """

        mockURLSession.cannedURLResponse = successURLResponse
        mockURLSession.cannedJSONData = jsonResponse

        let cardRequest = CardRequest(orderID: "", card: card)
        do {
            _ = try await cardClient.approveOrder(request: cardRequest)
            XCTFail("This should fail.")
        } catch let error as PayPalSDKError {
            XCTAssertEqual(error.domain, APIClientError.domain)
            XCTAssertEqual(error.code, APIClientError.Code.dataParsingError.rawValue)
            XCTAssertEqual(error.localizedDescription, "An error occured parsing HTTP response data. Contact developer.paypal.com/support.")
        } catch {
            XCTFail("Unexpected failure.")
        }
    }
}
