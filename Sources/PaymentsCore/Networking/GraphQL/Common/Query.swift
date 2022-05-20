//
//  Query.swift
//  Card
//
//  Created by Andres Pelaez on 19/05/22.
//

import Foundation

protocol Query {
    associatedtype T: Codable
    
    var queryParams: Dictionary<String, String> { get }
    var queryName: String { get }
    var dataFieldsForResponse: String { get }
    
    func queryParameters() -> String
    func requestBody() -> String
    func parse(data: Data) -> T
}

extension Query {
    
    func queryParameters() -> String {
        var params = String()
        for (key, value) in queryParams {
            params.append(contentsOf: "\n" + key + ":" + value)
        }
        return params
    }
    
    func requestBody() -> String {
        return """
            query { \(queryName) ( \(queryParameters()) )
            \(dataFieldsForResponse) }
        """
    }
    
    func parse(data: Data) -> T {
        do {
            let dataDecoded = try JSONDecoder().decode(type(of: <#T##T#>), from: data)
            return dataDecoded
        } catch {
            print(error.localizedDescription)
        }
    }
}
