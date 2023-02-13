import PPRiskMagnes

/// Enum of environments to use with PayPalDataCollector
public enum PayPalDataCollectorEnvironment {
    case sandbox
    case live

    var magnesEnvironment: MagnesSDK.Environment {
        switch self {
        case .sandbox:
            return .SANDBOX
        case .live:
            return .LIVE
        }
    }
}
