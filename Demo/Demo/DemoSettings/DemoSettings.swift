import UIKit

enum DemoSettings {

    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"
    private static let DemoTypeDefaultsKey = "demo_type"

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
}
