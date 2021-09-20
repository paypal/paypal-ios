import Foundation

class DemoSettings {
    
    enum Environment {
        case sandbox, production
        
        var baseURL: String {
            switch self {
            case .sandbox:
                return "https://ppcp-sample-merchant-sand.herokuapp.com"
            case .production:
                return "https://ppcp-sample-merchant-prod.herokuapp.com"
            }
        }
    }
    
}
