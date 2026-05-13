import Foundation
import XCTest
@testable import TestShared
@testable import CorePayments

class TrackingEventsAPI_Tests: XCTestCase {
    
    // MARK: - Helper Properties
    
    var sut: TrackingEventsAPI!
    var mockNetworkingClient: MockNetworkingClient!
    let coreConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
    let stubHTTPResponse = HTTPResponse(status: 200, body: nil)
    let fakeAnalyticsEventData = AnalyticsEventData(
        environment: "my-env",
        eventName: "my-event-name",
        clientID: "my-id",
        orderID: "my-order",
        correlationID: nil,
        setupToken: nil
    )
    
    // MARK: - Test Lifecycle
    
    override func setUp() {
        super.setUp()
        
        mockNetworkingClient = MockNetworkingClient()
        mockNetworkingClient.stubHTTPResponse = stubHTTPResponse
        sut = TrackingEventsAPI(coreConfig: coreConfig, networkingClient: mockNetworkingClient)
    }
    
    // MARK: - sendEvent() REST

    func testSendEvent_alwaysUsesLiveConfig() async throws {
        let sandboxConfig = CoreConfig(clientID: "fake-client-id", environment: .sandbox)
        let sut = TrackingEventsAPI(coreConfig: sandboxConfig, networkingClient: mockNetworkingClient)

        _ = try await sut.sendEvent(with: fakeAnalyticsEventData)

        XCTAssertNotNil(mockNetworkingClient.capturedRESTRequest, "Expected a REST request to be sent even with sandbox config")
        XCTAssertEqual(mockNetworkingClient.capturedRESTRequest?.path, "v1/tracking/events")
    }
    
    func testSendEvent_constructsRESTRequestForV1Tracking() async throws {
        let fakeAnalyticsEventData = AnalyticsEventData(
            environment: "my-env",
            eventName: "my-event-name",
            clientID: "my-id",
            orderID: "my-order",
            correlationID: "fake-correlation-id",
            setupToken: "fake-setup-token"
        )
        _ = try await sut.sendEvent(with: fakeAnalyticsEventData)
        
        XCTAssertEqual(mockNetworkingClient.capturedRESTRequest?.path, "v1/tracking/events")
        XCTAssertEqual(mockNetworkingClient.capturedRESTRequest?.method, .post)
        XCTAssertNil(mockNetworkingClient.capturedRESTRequest?.queryParameters)
        
        let postData = mockNetworkingClient.capturedRESTRequest?.postParameters as! AnalyticsEventData
        XCTAssertEqual(postData.environment, "my-env")
        XCTAssertEqual(postData.eventName, "my-event-name")
        XCTAssertEqual(postData.clientID, "my-id")
        XCTAssertEqual(postData.orderID, "my-order")
        XCTAssertEqual(postData.correlationID, "fake-correlation-id")
    }
    
    func testSendEvent_whenSuccess_bubblesHTTPResponse() async throws {
        let httpResponse = try await sut.sendEvent(with: fakeAnalyticsEventData)
        
        XCTAssertEqual(httpResponse, stubHTTPResponse)
    }
    
    func testSendEvent_whenError_bubblesNetworkingClientErrorThrow() async throws {
        mockNetworkingClient.stubHTTPError = CoreSDKError(code: 0, domain: "", errorDescription: "Fake error from NetworkingClient")
        
        do {
            _ = try await sut.sendEvent(with: fakeAnalyticsEventData)
            XCTFail("Expected an error to be thrown.")
        } catch {
            let error = error as NSError
            XCTAssertEqual(error.localizedDescription, "Fake error from NetworkingClient")
        }
    }
}
