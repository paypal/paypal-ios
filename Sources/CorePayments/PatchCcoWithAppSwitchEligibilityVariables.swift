import Foundation

struct ExperimentationContext: Encodable {

    let integrationChannel: String?
    init(integrationChannel: String? = PayPalCoreConstants.integrationChannel) {
        self.integrationChannel = integrationChannel
    }
}

struct PatchCcoWithAppSwitchEligibilityVariables: Encodable {

    let contextId: String
    let experimentationContext: ExperimentationContext?
    let osType: String
    let merchantOptInForAppSwitch: Bool
    let token: String
    let tokenType: String
    let integrationArtifact: String
    let paypalNativeAppInstalled: Bool?
}
