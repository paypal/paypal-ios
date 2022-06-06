import Foundation

extension URLSession: URLSessionProtocol {

   public func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        if #available(iOS 15, *) {
            return try await self.data(for: urlRequest)
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                let task = self.dataTask(with: urlRequest) { data, response, error in
                    guard let data = data, let response = response else {
                        let error = error ?? URLError(.badServerResponse)
                        return continuation.resume(throwing: error)
                    }

                    continuation.resume(returning: (data, response))
                }

                task.resume()
            }
        }
    }
}
