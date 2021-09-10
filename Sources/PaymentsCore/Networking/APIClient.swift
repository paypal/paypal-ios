//
//  APIClient.swift
//  PaymentsCore
//
//  Created by Nguyen, The Nhat Minh on 9/10/21.
//

import Foundation

enum HTTPMethod: String {
  /// Get
  case get = "GET"
  /// Head
  case head = "HEAD"
  /// Post
  case post = "POST"
  /// Put
  case put = "PUT"
  /// Delete
  case delete = "DELETE"
  /// Connect
  case connect = "CONNECT"
  /// Options
  case options = "OPTIONS"
  /// Patch
  case patch = "PATCH"
  /// Redirect
  case redirect = "REDIRECT"
}

enum HTTPHeader {
  case contentType(String)
  case authorization(String)
  
  var dictionary: [String: String] {
    switch self {
    case .contentType(let value):
      ["Content-Type": value]
    }
  }
}

enum SDKError: Error {
  case networkingError
}

class APIClient {

  var urlSession: URLSession
  
  init(urlSession: URLSession = .shared) {
    self.urlSession = urlSession
  }
  
  // Other convenience functions?
  // Reference: NXO
  // handle empty body?
  // make requests typed?
  // unit tests network request?
  

  func fetch<T: Codable>(
    url: URL,
    // path instead of url
    method: HTTPMethod,
    headers: [HTTPHeader],
    // params: [String: String]
    body: Data? = nil,
    completion: @escaping (Result<T, Error>) -> Void
  ) {
    let request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    if let body = body {
      request.httpBody = body
    }
    
    let task = urlSession.dataTask(with: request) { data, response, error in
      
      if let error = error {
        completion(.failure(error))
        return
      }
      
      switch response.statusCode {
      case 200..<300:
        
        guard data = data else {
          // no data
          return
        }

        // decode T from data
        do {
          let decodedData = try? JSONDecoder().decode(T.self, from: data)
          completion(.success(decodedData))
          return
        }
        catch let decodingError {
          completion(.failure(decodingError))
          return
        }
        
        
        // success
      default:
        completion(.failure(SDKError.networkingError))
        return
      }
    }
    
    task.resume()
  }
}
