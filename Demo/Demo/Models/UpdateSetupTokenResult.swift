struct UpdateSetupTokenResult: Decodable, Equatable, Hashable {

    var id: String
    var status: String?
    var didAttemptThreeDSecureAuthentication: Bool
}
