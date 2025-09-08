import Foundation

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
