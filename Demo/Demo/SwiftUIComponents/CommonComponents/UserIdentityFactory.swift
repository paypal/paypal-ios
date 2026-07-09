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
            let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedEmail = trimmedEmail.isEmpty ? nil : trimmedEmail
            let resolvedPhone = trimmedPhone.isEmpty ? nil : trimmedPhone
            guard resolvedEmail != nil || resolvedPhone != nil else { return nil }
            return PayPalUserIdentity(email: resolvedEmail, phone: resolvedPhone)
        case .ssid:
            let trimmedSSID = ssid.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedSSID.isEmpty else { return nil }
            return PayPalUserIdentity(existingPayPalSessionID: trimmedSSID)
        }
    }
}
