import Foundation

class AccessTokenRespose: Codable {
    var scope: String
    var access_token: String
    var token_type: String
    var expires_in: Int
    var nonce: String
}
