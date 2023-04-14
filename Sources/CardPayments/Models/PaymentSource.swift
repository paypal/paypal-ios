import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

public struct PaymentSource: Decodable {

    /// The card used as payment
    public let card: PaymentSource.Card

    public struct Card: Decodable {

        /// The last four digits of the provided card
        public let lastFourDigits: String?

        /// The card network
        /// - Examples: "VISA", "MASTERCARD"
        public let brand: String?

        /// The type of the provided card.
        /// - Examples: "DEBIT", "CREDIT"
        public let type: String?

        /// The result of the 3DS challenge
        public let authenticationResult: AuthenticationResult?
    }
}

public struct AuthenticationResult: Decodable {

    public let liabilityShift: String?
    public let threeDSecure: ThreeDSecure?
}

public struct ThreeDSecure: Decodable {

    public let enrollmentStatus, authenticationStatus: String?
}
