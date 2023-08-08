public struct UpdateVaultSetupTokenResponse: Codable {
    
    public let updateVaultSetupToken: TokenDetails
}

public struct TokenDetails: Codable {
    
    public let id: String
    public let status: String
    public let links: [Link]
    // we are not decoding payment source from update call
    // this is to reuse this field for get setup token call
    public let paymentSource: PaymentSourceInput?
}

public struct Link: Codable {
    
    public let rel: String
    public let href: String
}
