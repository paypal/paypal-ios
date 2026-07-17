import Foundation
import PayPalWebPayments

/// Shared factory for building a `PayPalUserIdentity` from the Demo app's
/// `UserIdentityView` selection. Used by both PayPalWeb and Vault flows.
enum UserIdentityFactory {

    static func makeUserIdentity(
        selection: UserIdentitySelection,
        email: String,
        phone: String,
        ssid: String
    ) -> PayPalUserIdentity? {
        switch selection {
        case .none:
            return nil
        case .buyerHints:
            let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedEmail = trimmedEmail.isEmpty ? nil : trimmedEmail
            let resolvedPhone = makePhoneNumber(from: phone)
            guard resolvedEmail != nil || resolvedPhone != nil else { return nil }
            return .init(email: resolvedEmail, phone: resolvedPhone)
        case .ssid:
            let trimmedSSID = ssid.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedSSID.isEmpty else { return nil }
            return .init(existingPayPalSessionID: trimmedSSID)
        }
    }

    // TODO: Refactor into a value-preserving `PayPalPhoneNumber(_:)` initializer on the SDK type,
    // per Swift API design guidelines (PR review nit) — replaces `makePhoneNumber(from:)` here.
    private static func makePhoneNumber(from phone: String) -> PayPalPhoneNumber? {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let parts = trimmed.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        if parts.count == 2 {
            return PayPalPhoneNumber(
                countryCode: String(parts[0]),
                nationalNumber: String(parts[1]).trimmingCharacters(in: .whitespaces)
            )
        }
        return PayPalPhoneNumber(countryCode: "", nationalNumber: trimmed)
    }
}
