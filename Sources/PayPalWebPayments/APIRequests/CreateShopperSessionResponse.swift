import Foundation

// TODO: full response will be in another PR
struct CreateShopperSessionResponse: Decodable {

    let external: ExternalNode?

    struct ExternalNode: Decodable {

        // swiftlint:disable:next identifier_name
        let createShopperSessionWithAppSwitchEligibility: SessionResultNode?
    }

    struct SessionResultNode: Decodable {

        let shopperSessionConfig: ShopperSessionConfig?
    }

    struct ShopperSessionConfig: Decodable {

        let id: String
    }
}
