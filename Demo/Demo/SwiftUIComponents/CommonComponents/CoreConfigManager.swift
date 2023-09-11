import Foundation
import CorePayments

class CoreConfigManager {

    let domain: String

    public init(domain: String) {
        self.domain = domain
    }

    func getClientID() async -> String? {
        await DemoMerchantAPI.sharedService.getClientID(
            environment: DemoSettings.environment,
            selectedMerchantIntegration: DemoSettings.merchantIntegration
        )
    }

    func getCoreConfig() async throws -> CoreConfig {
        guard let clientID = await getClientID() else {
            throw CoreSDKError(code: 0, domain: domain, errorDescription: "Error getting clientID")
        }
        
        return CoreConfig(clientID: clientID, environment: DemoSettings.environment.paypalSDKEnvironment)
    }
}
