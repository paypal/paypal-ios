import Foundation

struct PaymentsCoreError {

    static let domain = "PaymentsCoreErrorDomain"

    enum Code: Int {
        case unknown
        case connectionIssue
        case parsingError
        case invalidURLResponse
        case noResponseData
        case noURLRequest
    }

    let code: Code
}
