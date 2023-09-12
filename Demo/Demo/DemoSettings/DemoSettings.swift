import Foundation

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"
    private static let ClientIDKey = "clientID"
    private static let MerchantIntegrationDefaultKey = "merchantIntegration"

    static var environment: Environment {
        get {
            UserDefaults.standard.string(forKey: EnvironmentDefaultsKey)
                .flatMap { Environment(rawValue: $0) } ?? .sandbox
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: EnvironmentDefaultsKey)
        }
    }

    static var intent: Intent {
        UserDefaults.standard.string(forKey: IntentDefaultsKey)
            .flatMap { Intent(rawValue: $0) } ?? .capture
    }

    static var merchantIntegration: MerchantIntegration {
        get {
            UserDefaults.standard.string(forKey: MerchantIntegrationDefaultKey)
                .flatMap { MerchantIntegration(rawValue: $0) } ?? .direct
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: MerchantIntegrationDefaultKey)
        }
    }
}
