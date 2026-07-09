import PPRiskMagnes
#if canImport(CorePayments)
import CorePayments
#endif

extension CoreConfig {
    
    var magnesEnvironment: MagnesSDK.Environment {
        switch environment {
        case .sandbox:
            return .SANDBOX
        case .live:
            return .LIVE
        #if DEBUG
        case .custom:
            // Magnes has no custom environment; use sandbox for local/QA testing.
            return .SANDBOX
        #endif
        }
    }
}
