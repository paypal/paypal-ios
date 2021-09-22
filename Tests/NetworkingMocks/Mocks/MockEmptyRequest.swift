//
//  MockEmptyRequest.swift
//  MockEmptyRequest
//
//  Created by Jones, Jon on 9/21/21.
//

import Foundation
import PaymentsCore

class MockEmptyRequest: APIRequest, MockRequestResponse {
    typealias ResponseType = EmptyResponse

    var path: String { "/mock/request" }
    var method: HTTPMethod { .post }
    var headers: [HTTPHeader: String] { [:] }
    var body: Data? { Data() }

    var responseData: Data? = Data()
    let responseError: Error? = nil

    func canHandle(request: URLRequest) -> Bool {
        request.url?.path == path
    }

    func response(for request: URLRequest) -> HTTPURLResponse? {
        guard let url = request.url else {
            return nil
        }
        return HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [:])
    }
}

class MockNoReponseRequest: MockEmptyRequest {
    override func response(for request: URLRequest) -> HTTPURLResponse? {
        return nil
    }
}
