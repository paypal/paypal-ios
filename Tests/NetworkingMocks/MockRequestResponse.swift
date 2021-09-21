import Foundation

protocol MockRequestResponse {

    var responseData: Data? { get }

    func canHandle(request: URLRequest) -> Bool
    func response(for request: URLRequest) -> HTTPURLResponse
}
