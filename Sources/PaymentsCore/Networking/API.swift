
import UIKit

public protocol API {

    func send(_ apiRequest: APIRequest2, completion: @escaping (HttpResponse) -> Void)
}
