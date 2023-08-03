import Foundation
import CorePayments

class CheckoutOrdersAPI {
    
    let coreConfig: CoreConfig
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
    }
    
    func confirmPaymentSource(clientID: String, cardRequest: CardRequest) -> String { // ConfirmPaymentSourceResponse
        
        // let httpResult = http.send()
        // httpResponseParser
        
        return ""
    }
}

protocol RequestIT {
    
    associatedtype ResponseType: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader: String] { get }
    var queryParameters: [String: String] { get }
    var body: Data? { get }
}

class TrackingEventsAPI {
    
    let coreConfig: CoreConfig
    
    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
    }
    
    func sendEvent(_ name: String) -> String { // ConfirmPaymentSourceResponse
        
        return ""
    }
}

/// IDEAS DAY 2 -----------

protocol RestRequest {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [HTTPHeader: String] { get }
    var queryParameters: [String: String] { get }
    var body: Encodable? { get }
}

protocol GraphQLRequest {
    
}

class NetworkingClient {
    
    // need env
    
    func performRequest(request: RestRequest, response: Decodable) {
        // construct URLRequest
            // encode POST body if present
        // kick of HTTP.send()
        // do HTTPParser.parse() if needed
    }
    
    func performRequest(request: GraphQLRequest) {
        // construct URLRequest
            // encode POST body
        // kick of HTTP.send()
        // do HTTPParser.parse(), specific to graphQL
    }
}

// Move encoding responsibility out of APIRequest
// Move association of request & response parse associated type
// easier to unit test
