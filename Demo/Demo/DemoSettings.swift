import Foundation

class DemoSettings {

    static var sharedSettings = DemoSettings()

    private init() {}

    var environment: Environment {
        // TODO: pull settings from a shared config - for now, just hardcoding to sandbox
        .sandbox
    }

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

    // TODO: add other settings configuration here
}
