import Foundation

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

class DemoSettings {
    
    static let EnvironmentDefaultsKey = "environment"
    static let IntentDefaultsKey = "intent"
    
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

}
