import Foundation
import CorePayments

class CoreConfigManager {

    let domain: String

    public init(domain: String) {
        self.domain = domain
    }

    func getClientID() -> String {
        DemoMerchantAPI.shared.getClientID(environment: DemoSettings.environment)
    }

    func getCoreConfig() -> CoreConfig {
        let clientID = getClientID()
        return CoreConfig(
            clientID: clientID,
            environment: DemoSettings.environment.paypalSDKEnvironment,
            merchantID: DemoSettings.merchantIntegration.merchantID
        )
    }
}
