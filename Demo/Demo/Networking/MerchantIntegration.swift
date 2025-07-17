import Foundation

enum MerchantIntegration: Hashable {

    case direct(clientID: String)

    static var `default`: MerchantIntegration {
        return .direct(clientID: "AQTfw2irFfemo-eWG4H5UY-b9auKihUpXQ2Engl4G1EsHJe2mkpfUv_SN3Mba0v3CfrL6Fk_ecwv9EOo")
    }

    var path: String {
        switch self {
        case .direct:
            return ""
        }
    }

    var clientID: String {
        switch self {
        case .direct(let clientID):
            return clientID
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
            .direct(clientID: "AQTfw2irFfemo-eWG4H5UY-b9auKihUpXQ2Engl4G1EsHJe2mkpfUv_SN3Mba0v3CfrL6Fk_ecwv9EOo")
        ]
    }

    static func from(displayName: String, withClientID clientID: String) -> MerchantIntegration? {
        switch displayName {
        case "direct":
            return .direct(clientID: "AQTfw2irFfemo-eWG4H5UY-b9auKihUpXQ2Engl4G1EsHJe2mkpfUv_SN3Mba0v3CfrL6Fk_ecwv9EOo")
        default: return nil
        }
    }
}
