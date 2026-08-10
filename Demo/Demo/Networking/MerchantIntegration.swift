import Foundation

enum MerchantIntegration: Hashable {

    // The credentials are resolved from the selected environment rather than carried as
    // associated values, so the value stays stable as `Picker` selection/tag while switching
    // between sandbox and live.
    case direct

    static var `default`: MerchantIntegration {
        return .direct
    }

    var path: String {
        switch self {
        case .direct:
            return ""
        }
    }

    var clientID: String {
        switch self {
        case .direct:
            return DemoSettings.environment == .live ? Self.liveClientID : Self.sandboxClientID
        }
    }
    
    var merchantID: String {
        switch self {
        case .direct:
            return DemoSettings.environment == .live ? Self.liveMerchantID : Self.testMerchantID
        }
    }

    var displayName: String {
        switch self {
        case .direct:
            return "direct"
        }
    }

    static var allCases: [MerchantIntegration] {
        return [.direct]
    }
    
    private static let sandboxClientID = "AQTfw2irFfemo-eWG4H5UY-b9auKihUpXQ2Engl4G1EsHJe2mkpfUv_SN3Mba0v3CfrL6Fk_ecwv9EOo"
    private static let testMerchantID = "4781436711037045243"

    private static let liveClientID = "AYgaQtnz7wZVZM7ODhuVL16QczZLvZ14cBjuasBZZnIXH7pKLS1DoPuF-eS-Eg5PsTXv4gYkoOOrFS2J"
    private static let liveMerchantID = "8AYC6TF2L3D7W"

    static func from(displayName: String, withClientID clientID: String) -> MerchantIntegration? {
        switch displayName {
        case "direct":
            return .direct
        default: return nil
        }
    }
}
