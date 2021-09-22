import Foundation

enum Environment: String {
    case sandbox = "sandbox"
    case production = "production"
    
    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://ppcp-sample-merchant-sand.herokuapp.com"
        case .production:
            return "https://ppcp-sample-merchant-prod.herokuapp.com"
        }
    }
}

class DemoSettings {
    
    static let EnvironmentDefaultsKey = "environment"
    
    static var environment: Environment {
        guard let defaultsValue = UserDefaults.standard.string(forKey: EnvironmentDefaultsKey),
              let environment = Environment(rawValue: defaultsValue) else {
                  return .sandbox
              }
        return environment
    }

}
