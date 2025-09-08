import Foundation
@testable import CorePayments

class MockAuthenticationSecureTokenServiceAPI: AuthenticationSecureTokenServiceAPI {

    var stubbedAccessToken: String = "lsat_stubbed"
    var stubbedError: Error?

    override init(coreConfig: CoreConfig) {
        super.init(coreConfig: coreConfig)
    }

    override func createLowScopedAccessToken() async throws -> AuthTokenResponse {
        if let err = stubbedError { throw err }
        return AuthTokenResponse(
            accessToken: stubbedAccessToken,
            tokenType: "Bearer"
        )
    }
}
