import UIKit

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"
    private static let DemoTypeDefaultsKey = "demo_type"
    private static let DemoUIFrameworkKey = "demo_ui_framework"

    static var environment: Environment {
        UserDefaults.standard.string(forKey: EnvironmentDefaultsKey)
            .flatMap { Environment(rawValue: $0) } ?? .sandbox
    }

    static var intent: Intent {
        UserDefaults.standard.string(forKey: IntentDefaultsKey)
            .flatMap { Intent(rawValue: $0) } ?? .capture
    }

    static var demoType: DemoType {
        UserDefaults.standard.string(forKey: DemoTypeDefaultsKey)
            .flatMap { DemoType(rawValue: $0) } ?? .card
    }

    static var demoUIFramework: DemoUIFramework {
        UserDefaults.standard.string(forKey: DemoUIFrameworkKey)
            .flatMap { DemoUIFramework(rawValue: $0) } ?? .uikit
    }

    static var clientID: String {
        switch environment {
        case .sandbox:
            return "ASUApeBhpz9-IhrBRpHbBfVBklK4XOr1lvZdgu1UlSK0OvoJut6R-zPUP7iufxso55Yvyl6IZYV3yr0g"
        case .production:
            // TODO: Investigate getting a prod testing account that doesn't charge real money
            return "TODO"
        }
    }

    static var paypalReturnUrl: String {
        switch environment {
        case .sandbox:
            return "northstar://paypalpay"
        case .production:
            // TODO: Investigate getting a prod testing account that doesn't charge real money
            return "TODO"
        }
    }
}
