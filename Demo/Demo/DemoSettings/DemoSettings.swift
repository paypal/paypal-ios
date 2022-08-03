import UIKit

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"
    private static let DemoTypeDefaultsKey = "demo_type"
    private static let DemoUIFrameworkKey = "demo_ui_framework"
    private static let ClientIdKey = "clientId"

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

    static var demoUIFramework: DemoUIFramework {
        UserDefaults.standard.string(forKey: DemoUIFrameworkKey)
            .flatMap { DemoUIFramework(rawValue: $0) } ?? .uikit
    }

    static var clientID: String {
        switch environment {
        case .sandbox:
            return "AcXwOk3dof7NCNcriyS8RVh5q39ozvdWUF9oHPrWqfyrDS4AwVdKe32Axuk2ADo6rI_31Vv6MGgOyzRt"
        case .production:
            // TODO: Investigate getting a prod testing account that doesn't charge real money
            return "TODO"
        }
    }
}
