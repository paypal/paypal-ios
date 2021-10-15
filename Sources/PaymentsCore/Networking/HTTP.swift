import UIKit

protocol HTTP {

    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPResponse) -> Void)
}
