//
//  GraphQLClient.swift
//  Card
//
//  Created by Andres Pelaez on 19/05/22.
//

class GraphQLClient {
    
    
    func executeQuery<T: Codable>(query: Query) -> GraphQLQueryResponse<T> {
//        let request = GraphQLQueryResponse<Codable>(
//
//        )
        
//        let completeUrl = environment.baseURL.appendingPathComponent(path)
//        var urlComponents = URLComponents(url: completeUrl, resolvingAgainstBaseURL: false)
//
//        queryParameters.forEach {
//            urlComponents?.queryItems?.append(URLQueryItem(name: $0.key, value: $0.value))
//        }
//
//        guard let url = urlComponents?.url else {
//            return nil
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = method.rawValue
//        request.httpBody = body
//
//        headers.forEach { key, value in
//            request.addValue(value, forHTTPHeaderField: key.rawValue)
//        }

        return request
    }
}
