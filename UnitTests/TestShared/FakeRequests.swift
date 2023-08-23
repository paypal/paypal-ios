import Foundation
import CorePayments

public struct FakeResponse: Decodable {

    var fakeParam: String
}

public struct FakeRequest: Encodable {
    
    var fakeParam: String
}
