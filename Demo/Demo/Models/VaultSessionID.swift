struct VaultSessionID: Codable {

    let status: String?
    let links: [LinkResponse]
}

struct LinkResponse: Codable {

    let href: String?
    let rel: String?
    let method: String?
    let encType: String?
}
