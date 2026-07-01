import Foundation

// TODO: full response will be in another PR
struct CreateShopperSessionResponse: Decodable {

    let external: ExternalNode?

    struct ExternalNode: Decodable {

        let sessionResult: SessionResultNode?

        private enum CodingKeys: String, CodingKey {
            case sessionResult = "createShopperSessionWithAppSwitchEligibility"
        }
    }

    struct SessionResultNode: Decodable {

        let shopperSessionConfig: ShopperSessionConfig?
    }

    struct ShopperSessionConfig: Decodable {

        let id: String
    }
}
