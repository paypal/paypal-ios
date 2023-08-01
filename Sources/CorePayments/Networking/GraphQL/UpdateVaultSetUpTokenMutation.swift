import Foundation

public struct PaymentSourceInput: Codable {
    
    let card: VaultCard

    public init(card: VaultCard) {
        self.card = card
    }
}

public struct VaultCard: Codable {
    
    let number: String
    let expiry: String
    let name: String?
    let securityCode: String
    let billingAddress: Address?
    
    public init(number: String, expiry: String, name: String? = nil, securityCode: String, billingAddress: Address? = nil) {
        self.number = number
        self.expiry = expiry
        self.name = name
        self.securityCode = securityCode
        self.billingAddress = billingAddress
    }
}

public struct Address: Codable {
    
    let postalCode: String?
    let addressLine1: String?
    let addressLine2: String?
    let adminArea1: String?
    let adminArea2: String?
    let countryCode: String
}

public struct Variables: Codable {
    
    let clientID: String
    let vaultSetupToken: String
    let paymentSource: PaymentSourceInput
}

public class UpdateVaultSetupTokenMutation: GraphQLQuery, Codable {
    
    public var query: String
    public var variables: Variables?
    
        public init(
            clientID: String,
            vaultSetupToken: String,
            paymentSource: PaymentSourceInput
        ) {
            self.variables = Variables(
                clientID: clientID,
                vaultSetupToken: vaultSetupToken,
                paymentSource: paymentSource
            )
            let queryString = """
                mutation UpdateVaultSetupToken(
                    $clientID: String!,
                    $vaultSetupToken: String!,
                    $paymentSource: PaymentSource
                ) {
                    updateVaultSetupToken(
                        clientId: $clientID
                        vaultSetupToken: $vaultSetupToken
                        paymentSource: $paymentSource
                        ) {
                            id,
                            status,
                            links {
                                rel, href
                            }
                        }
                }
                """
            self.query = queryString
        }
}
