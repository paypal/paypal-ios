import Foundation

extension URLSession {
    convenience init<Protocol: URLProtocol>(urlProtocol: Protocol.Type) {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [urlProtocol]
        self.init(configuration: configuration)
        URLProtocol.registerClass(urlProtocol)
    }
}
