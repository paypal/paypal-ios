import Foundation


public struct ThreeDSecureRequest {

    /// Specificy to always launch 3DS or only when required
    public let sca: SCA

    /// Url to return after flow has completed
    public let returnUrl: String

    /// Url to return when flow is cancelled
    public let cancelUrl: String

    /// Creates an instance of a card request
    /// - Parameters:
    ///   - sca: Specificy to always launch 3DS or only when required
    ///   - returnUrl: Url to return after flow has completed
    ///   - cancelUrl: Url to return when flow is cancelled
    public init(sca: SCA, returnUrl: String, cancelUrl: String) {
        self.sca = sca
        self.returnUrl = returnUrl
        self.cancelUrl = cancelUrl
    }
}

internal struct Attributes: Codable {

    let verification: Verification
}

internal struct Verification: Codable {

    let method: String
}

// MARK: - AuthenticationResult
public struct AuthenticationResult: Decodable {

    public let liabilityShift: String?
    public let threeDSecure: ThreeDSecure?
}

// MARK: - ThreeDSecure
public struct ThreeDSecure: Decodable {

    public let enrollmentStatus, authenticationStatus: String?
}
