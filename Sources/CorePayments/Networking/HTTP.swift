import Foundation

/// `HTTP` constructs `URLRequest`s and interfaces directly with `URLSession` to execute network requests.
class HTTP {
    
    let coreConfig: CoreConfig
    private var urlSession: URLSessionProtocol

    init(
        urlSession: URLSessionProtocol = URLSession.shared,
        coreConfig: CoreConfig
    ) {
        self.urlSession = urlSession
        self.coreConfig = coreConfig
    }
    
    func performRequest(_ httpRequest: HTTPRequest) async throws -> HTTPResponse {
        var urlRequest = URLRequest(url: httpRequest.url)
        urlRequest.httpMethod = httpRequest.method.rawValue
        urlRequest.httpBody = httpRequest.body
        
        httpRequest.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key.rawValue)
        }

        HTTP.logRequest(httpRequest)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await urlSession.performRequest(with: urlRequest)
        } catch let error as URLError {
            HTTP.logTransportError(error, for: httpRequest)
            throw NetworkingError.urlSessionError
        } catch {
            HTTP.logTransportError(error, for: httpRequest)
            throw NetworkingError.unknownError
        }

        guard let response = response as? HTTPURLResponse else {
            throw NetworkingError.invalidURLResponseError
        }
        
        HTTP.logResponse(status: response.statusCode, body: data, for: httpRequest)

        return HTTPResponse(status: response.statusCode, body: data)
    }
}

#if DEBUG
extension HTTP {

    private static func isTrackingRequest(_ request: HTTPRequest) -> Bool {
        request.url.absoluteString.hasSuffix("tracking/events")
    }

    private static func logRequest(_ request: HTTPRequest) {
        guard !isTrackingRequest(request) else { return }
        var lines = ["📡 [PayPal SDK] ➡️ REQUEST", "\(request.method.rawValue) \(request.url.absoluteString)"]
        let headers = request.headers
            .map { "\($0.key.rawValue): \(redactedHeaderValue(key: $0.key.rawValue, value: $0.value))" }
            .sorted()
        if !headers.isEmpty {
            lines.append("Headers:\n\(headers.joined(separator: "\n"))")
        }
        lines.append("Body: \(bodyString(request.body))")
        print(lines.joined(separator: "\n"))
    }

    private static func logResponse(status: Int, body: Data?, for request: HTTPRequest) {
        guard !isTrackingRequest(request) else { return }
        let statusIcon = (200..<300).contains(status) ? "✅" : "⚠️"
        print(
            """
            📡 [PayPal SDK] ⬅️ RESPONSE \(statusIcon) \(status)
            \(request.method.rawValue) \(request.url.absoluteString)
            Body: \(bodyString(body))
            """
        )
    }

    private static func logTransportError(_ error: Error, for request: HTTPRequest) {
        guard !isTrackingRequest(request) else { return }
        print(
            """
            📡 [PayPal SDK] ❌ TRANSPORT ERROR
            \(request.method.rawValue) \(request.url.absoluteString)
            Error: \(error.localizedDescription)
            """
        )
    }

    private static func bodyString(_ data: Data?) -> String {
        guard let data, !data.isEmpty else {
            return "<empty>"
        }
        return String(data: data, encoding: .utf8) ?? "<\(data.count) bytes, non-UTF8>"
    }

    private static func redactedHeaderValue(key: String, value: String) -> String {
        guard key.lowercased() == HTTPHeader.authorization.rawValue.lowercased() else {
            return value
        }
        let parts = value.split(separator: " ", maxSplits: 1)
        if let scheme = parts.first {
            return "\(scheme) <redacted>"
        }
        return "<redacted>"
    }
}
#endif
