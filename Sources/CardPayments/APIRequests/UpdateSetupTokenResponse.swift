struct UpdateSetupTokenResponse: Codable {
    
    let updateVaultSetupToken: TokenDetails
}

struct TokenDetails: Codable {

    struct Link: Codable {

        let rel: String
        let href: String
    }

    let id: String
    let status: String
    let links: [Link]
}
