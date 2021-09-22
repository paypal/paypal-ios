import UIKit

enum Environment: String {
    case sandbox
    case production
    
    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://ppcp-sample-merchant-sand.herokuapp.com"
        case .production:
            return "https://ppcp-sample-merchant-prod.herokuapp.com"
        }
    }
}

enum Intent: String {
    case capture = "CAPTURE"
    case authorize = "AUTHORIZE"
}

// TODO: Should the demo toggle logic live elsewhere, or in this DemoSettings file?
enum DemoType: String {
    case card
    case paypal
    
    var viewController: UIViewController.Type {
        switch self {
        case .card:
            return CardDemoViewController.self
        case .paypal:
            return PayPalDemoViewController.self
        }
    }
}

final class DemoSettings {
    
    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"
    private static let DemoTypeDefaultsKey = "demo_type"
    
    static var environment: Environment {
        UserDefaults.standard.string(forKey: EnvironmentDefaultsKey).flatMap( { Environment(rawValue: $0) }) ?? .sandbox
    }
    
    static var intent: Intent {
        UserDefaults.standard.string(forKey: IntentDefaultsKey).flatMap( { Intent(rawValue: $0) }) ?? .capture
    }

    static var demoType: DemoType {
        UserDefaults.standard.string(forKey: IntentDefaultsKey).flatMap( { DemoType(rawValue: $0) }) ?? .card
    }
}
