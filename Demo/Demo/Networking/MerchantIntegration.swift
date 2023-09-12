import Foundation

enum MerchantIntegration: String, CaseIterable {
    case direct
    case connectedPath
    case managedPath
    
    var path: String {
        switch self {
        case .direct:
            return "/direct"
        case .connectedPath:
            return "/connected_path"
        case .managedPath:
            return "/managed_path"
        }
    }
}
