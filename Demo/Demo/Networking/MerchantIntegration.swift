import Foundation

enum MerchantIntegration: Hashable {

    case direct(clientID: String, merchantID: String)

    static var `default`: MerchantIntegration {
        return .direct(
            clientID: testClientID,
            merchantID: testMerchantID
        )
    }

    var path: String {
        switch self {
        case .direct:
            return ""
        }
    }

    var clientID: String {
        switch self {
        case .direct(let clientID, _):
            return clientID
        }
    }
    
    var merchantID: String {
        switch self {
        case .direct(_, let merchantID):
            return merchantID
        }
    }

    var displayName: String {
        switch self {
        case .direct:
            return "direct"
        }
    }

    static var allCases: [MerchantIntegration] {
        return [
            .direct(
                clientID: testClientID,
                merchantID: testMerchantID
            )
        ]
    }
    
    private static let testClientID = "AQTfw2irFfemo-eWG4H5UY-b9auKihUpXQ2Engl4G1EsHJe2mkpfUv_SN3Mba0v3CfrL6Fk_ecwv9EOo"
    private static let testMerchantID = "4781436711037045243"

    static func from(displayName: String, withClientID clientID: String) -> MerchantIntegration? {
        switch displayName {
        case "direct":
            return .direct(
                clientID: testClientID,
                merchantID: testMerchantID
            )
        default: return nil
        }
    }
}
