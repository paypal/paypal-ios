import Foundation

// MARK: - Variables

struct ExperimentationContext: Encodable {

    let integrationChannel: String?
    init(integrationChannel: String? = "PPCP_NATIVE_SDK") {
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

// MARK: - Response (data-only)

@_documentation(visibility: private)
public struct PatchCcoWithAppSwitchEligibilityResponse: Decodable {

    let external: ExternalNode?

    struct ExternalNode: Decodable {

        let patchCcoWithAppSwitchEligibility: PatchNode?
    }

    struct PatchNode: Decodable {

        let appSwitchEligibility: AppSwitchEligibility?
    }
}

@_documentation(visibility: private)
public struct AppSwitchEligibility: Decodable {
    
    public let appSwitchEligible: Bool?
    public let redirectURL: String?
    public let ineligibleReason: String?
}
