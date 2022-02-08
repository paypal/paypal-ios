//
//  URLSessionProtocol.swift
//  PaymentsCore
//
//  Created by Steven Shropshire on 2/8/22.
//

import Foundation

protocol URLSessionProtocol {
    func performRequest(with urlRequest: URLRequest) async throws -> (Data, URLResponse)
}
