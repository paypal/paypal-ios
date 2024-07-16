import XCTest
import AuthenticationServices
@testable import VenmoPayments
@testable import CorePayments
@testable import TestShared

public class VenmoClient_Tests: XCTestCase {
    
    var config: CoreConfig!
    var venmoClient: VenmoClient!
    var mockNetworkingClient: MockNetworkingClient!
    
    override func setUp() {
        super.setUp()
        config = CoreConfig(clientID: "test-client-id", environment: .sandbox)
        mockNetworkingClient = MockNetworkClient(http: MockHTTP(coreConfig: config))
    }
    
    // TODO: Add other relevant unit tests in a future PR
}
