
import UIKit

public protocol API {

    func send(_ apiRequest: APIRequest, completion: @escaping (HttpResponse) -> Void)
}
