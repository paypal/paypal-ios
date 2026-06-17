import Foundation
import PayPalWebPayments

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let ClientIDKey = "clientID"
    private static let MerchantIntegrationDefaultKey = "merchantIntegration"
    private static let ManualTestingDefaultsKey = "manualTesting"

    /// Stub SSID GraphQL until backend API is ready.
    /// Set to `false` and remove ManualTesting code when API ships.
    static var manualTesting: Bool {
        get {
            if UserDefaults.standard.object(forKey: ManualTestingDefaultsKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: ManualTestingDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: ManualTestingDefaultsKey)
            applyManualTestingConfiguration()
        }
    }

    static func applyManualTestingConfiguration() {
#if DEBUG
        PayPalWebPaymentsManualTesting.isEnabled = manualTesting
#endif
    }

    static var environment: Environment {
        get {
            UserDefaults.standard.string(forKey: EnvironmentDefaultsKey)
                .flatMap { Environment(rawValue: $0) } ?? .sandbox
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: EnvironmentDefaultsKey)
        }
    }

    static var merchantIntegration: MerchantIntegration {
        get {
            if let savedDisplayName = UserDefaults.standard.string(forKey: MerchantIntegrationDefaultKey),
            let matchingCase = MerchantIntegration.allCases.first(where: { $0.displayName == savedDisplayName }) {
                return matchingCase
            }
            return MerchantIntegration.default
        }
        set {
            UserDefaults.standard.set(newValue.displayName, forKey: MerchantIntegrationDefaultKey)
        }
    }
}
