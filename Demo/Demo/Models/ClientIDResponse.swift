struct ClientIDResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case clientID = "value"
    }

    let clientID: String
}
