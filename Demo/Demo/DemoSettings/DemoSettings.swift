import Foundation

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"
    private static let DemoTypeDefaultsKey = "demo_type"
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

    static var demoType: DemoType {
        get {
            UserDefaults.standard.string(forKey: DemoTypeDefaultsKey)
                .flatMap { DemoType(rawValue: $0) } ?? .card
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: DemoTypeDefaultsKey)
        }
    }

    static var merchantIntegration: MerchantIntegration {
        get {
            UserDefaults.standard.string(
                forKey: MerchantIntegrationDefaultKey)
            .flatMap { MerchantIntegration(rawValue: $0) } ?? .unspecified
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: MerchantIntegrationDefaultKey)
        }
    }

    static var clientID: String {
        switch (environment, merchantIntegration) {
        case (.sandbox, .unspecified):
            return "AcXwOk3dof7NCNcriyS8RVh5q39ozvdWUF9oHPrWqfyrDS4AwVdKe32Axuk2ADo6rI_31Vv6MGgOyzRt"
        case (.sandbox, .direct):
            return "AVhcAP8TDu5PFeAw97M8187g-iYQW8W0AhvvXaMaWPojJRGGkunX8r-fyPkKGCv09P83KC2dijKLKwyz"
        case (.sandbox, .connectedPath):
            return "AcvkeOozOElJtQoZxxdAsDUrsClbAiNv7KIW6675dAiC7EX5R0wvSPiUNCc2JPEKHyFPfegwh_OV2afV"
        case (.sandbox, .managedPath):
            return "Afba8WbtSOqWlMoxroE5Ym8CVnogJJcHpj2uFpPYzN7oJz8NOi9XRrmHmpbWVQm6vRX0SwCvabaNKo06"
        case (.live, _):
            // TODO: Investigate getting a prod testing account that doesn't charge real money
            return "TODO"
        }
    }
}
