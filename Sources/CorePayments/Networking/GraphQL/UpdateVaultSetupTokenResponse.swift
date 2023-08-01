public struct UpdateVaultSetupTokenResponse: Codable {
    
    public let updateVaultSetupToken: TokenDetails
}

public struct TokenDetails: Codable {
    
    public let id: String
    public let status: String
    public let links: [Link]
}

public struct Link: Codable {
    
    public let rel: String
    public let href: String
}
