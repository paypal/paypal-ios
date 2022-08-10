struct GetClientIDResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case clientID = "clientId"
    }

    let clientID: String
}
