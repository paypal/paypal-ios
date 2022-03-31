import PPRiskMagnes

/// Enum of environments to use with PayPalDataCollector
public enum PayPalDataCollectorEnvironment {
    case sandbox
    case production

    var magnesEnvironment: MagnesSDK.Environment {
        switch self {
        case .sandbox:
            return .SANDBOX
        case .production:
            return .LIVE
        }
    }
}
