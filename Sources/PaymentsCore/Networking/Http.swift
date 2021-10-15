
import UIKit

protocol Http {

    func send(_ urlRequest: URLRequest, completion: @escaping (HttpResponse) -> Void)
}
