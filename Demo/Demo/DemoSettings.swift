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
    case capture
    case authorize
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
        guard let defaultsValue = UserDefaults.standard.string(forKey: EnvironmentDefaultsKey),
              let environment = Environment(rawValue: defaultsValue) else {
                  return .sandbox
              }
        return environment
    }
    
    static var intent: Intent {
        guard let defaultsValue = UserDefaults.standard.string(forKey: IntentDefaultsKey),
              let intent = Intent(rawValue: defaultsValue) else {
                  return .capture
              }
        return intent
    }
    
    static var demoType: DemoType {
        guard let defaultsValue = UserDefaults.standard.string(forKey: DemoTypeDefaultsKey),
              let demoType = DemoType(rawValue: defaultsValue) else {
                  return .card
              }
        return demoType
    }

}
