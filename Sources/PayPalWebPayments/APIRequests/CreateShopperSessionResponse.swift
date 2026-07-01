import Foundation

struct CreateShopperSessionResponse: Decodable {

    let external: ExternalNode?

    struct ExternalNode: Decodable {
        let createShopperSessionWithAppSwitchEligibility: SessionResultNode?
    }

    struct SessionResultNode: Decodable {
        let shopperSessionConfig: ShopperSessionConfig?
    }

    struct ShopperSessionConfig: Decodable {
        let id: String
    }
}
