import Foundation

class DemoSettings {
    
    enum Environment {
        case sandbox, production
        
        var baseURL: URL {
            switch self {
            case .sandbox:
                return URL(string: "https://ppcp-sample-merchant-sand.herokuapp.com")!
            case .production:
                return URL(string: "https://ppcp-sample-merchant-prod.herokuapp.com")!
            }
        }
    }
    
}
