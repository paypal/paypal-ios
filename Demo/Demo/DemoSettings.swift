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

final class DemoSettings {
    
    private static let EnvironmentDefaultsKey = "environment"
    private static let IntentDefaultsKey = "intent"

    static var environment: Environment {
        return UserDefaults.standard.string(forKey: EnvironmentDefaultsKey).flatMap( { Environment(rawValue: $0) }) ?? .sandbox
    }
    
    static var intent: Intent {
        return UserDefaults.standard.string(forKey: IntentDefaultsKey).flatMap( { Intent(rawValue: $0) }) ?? .capture
    }
}
