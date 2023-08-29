import CorePayments

enum Environment: String, CaseIterable {
    case sandbox
    case live

    var baseURL: String {
        switch self {
        case .sandbox:
            return "https://sdk-sample-merchant-server.herokuapp.com"
        case .live:
            return "https://sdk-sample-merchant-server.herokuapp.com"
        }
    }

    var paypalSDKEnvironment: CorePayments.Environment {
        switch self {
        case .sandbox:
            return .sandbox
        case .live:
            return .live
        }
    }
}
