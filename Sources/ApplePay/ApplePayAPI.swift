import Foundation
#if canImport(CorePayments)
import CorePayments
#endif

protocol ApplePayServicing {
    func fetchConfig(buyerCountry: String?) async throws -> ApplePayConfig
    func confirm(orderID: String, authorization: ApplePayAuthorization) async throws -> String
}

/// Talks to the same PayPal GraphQL operations the web Apple Pay JS SDK uses.
final class ApplePayAPI: ApplePayServicing {

    private let coreConfig: CoreConfig
    private let networkingClient: NetworkingClient

    init(coreConfig: CoreConfig) {
        self.coreConfig = coreConfig
        self.networkingClient = NetworkingClient(coreConfig: coreConfig)
    }

    init(coreConfig: CoreConfig, networkingClient: NetworkingClient) {
        self.coreConfig = coreConfig
        self.networkingClient = networkingClient
    }

    func fetchConfig(buyerCountry: String?) async throws -> ApplePayConfig {
        let variables = ApplePayConfigVariables(
            buyerCountry: buyerCountry,
            clientId: coreConfig.clientID,
            merchantId: [coreConfig.merchantID]
        )
        let response = try await send(
            query: ApplePayGraphQL.configQuery,
            variables: variables,
            name: "GetApplepayConfig"
        )
        let decoded = try decode(response, as: ApplePayConfigEnvelope.self)
        guard let config = decoded.applepayConfig else {
            throw ApplePayError.notEligible
        }
        return config
    }

    func confirm(orderID: String, authorization: ApplePayAuthorization) async throws -> String {
        let variables = ApproveApplePayVariables(
            token: authorization.token,
            orderID: orderID,
            clientID: coreConfig.clientID,
            billingContact: authorization.billingContact,
            shippingContact: authorization.shippingContact,
            productFlow: "CUSTOM_DIGITAL_WALLET"
        )
        let response = try await send(
            query: ApplePayGraphQL.approveQuery,
            variables: variables,
            name: "ApproveApplePayPayment",
            headers: partnerHeaders
        )
        let decoded = try decode(response, as: ApproveApplePayEnvelope.self)
        return try approvalStatus(from: decoded.approveApplePayPayment)
    }

    private var partnerHeaders: [HTTPHeader: String] {
        guard let bnCode = coreConfig.bnCode, !bnCode.isEmpty else {
            return [:]
        }
        return [.payPalPartnerAttributionId: bnCode]
    }

    private func send(
        query: String,
        variables: Encodable,
        name: String,
        headers: [HTTPHeader: String] = [:]
    ) async throws -> HTTPResponse {
        let request = GraphQLRequest(query: query, variables: variables, queryNameForURL: name)
        return try await networkingClient.fetch(request: request, additionalHeaders: headers)
    }

    private func decode<T: Decodable>(_ response: HTTPResponse, as type: T.Type) throws -> T {
        guard let body = response.body else {
            throw NetworkingError.noResponseDataError
        }
        if !response.isSuccessful {
            _ = try HTTPResponseParser().parseGraphQL(response, as: T.self)
            throw ApplePayError.unknown
        }
        let envelope = try JSONDecoder().decode(GraphQLEnvelope<T>.self, from: body)
        if let message = envelope.errors?.first?.message, !message.isEmpty {
            throw ApplePayError.confirmationFailed(message)
        }
        guard let data = envelope.data else {
            throw NetworkingError.noGraphQLDataKey
        }
        return data
    }

    private func approvalStatus(from value: JSONValue) throws -> String {
        switch value {
        case .bool(true):
            return "APPROVED"
        case .string(let status) where !status.isEmpty:
            return status
        case .object(let object):
            if case .string(let status) = object["status"], !status.isEmpty {
                return status
            }
            return "APPROVED"
        default:
            throw ApplePayError.confirmationFailed("PayPal declined the Apple Pay payment.")
        }
    }
}

enum ApplePayGraphQL {

    static let configQuery = """
        query GetApplepayConfig($buyerCountry: CountryCodes, $clientId: String!, $merchantId: [String]!) {
            applepayConfig(buyerCountry: $buyerCountry, clientId: $clientId, merchantId: $merchantId) {
                merchantCountry
                supportedNetworks
                isEligible
                merchantCapabilities
                tokenNotificationURL
            }
        }
        """

    static let approveQuery = """
        mutation ApproveApplePayPayment(
            $token: ApplePayPaymentToken!,
            $orderID: String!,
            $clientID: String!,
            $billingContact: ApplePayPaymentContact!,
            $shippingContact: ApplePayPaymentContact,
            $productFlow: String
        ) {
            approveApplePayPayment(
                token: $token,
                orderID: $orderID,
                clientID: $clientID,
                billingContact: $billingContact,
                shippingContact: $shippingContact,
                productFlow: $productFlow
            )
        }
        """
}

struct ApplePayConfigVariables: Encodable {

    let buyerCountry: String?
    let clientId: String
    let merchantId: [String]

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(merchantId, forKey: .merchantId)
        if let buyerCountry {
            try container.encode(buyerCountry, forKey: .buyerCountry)
        } else {
            try container.encodeNil(forKey: .buyerCountry)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case buyerCountry
        case clientId
        case merchantId
    }
}

struct ApproveApplePayVariables: Encodable {

    let token: ApplePayPaymentToken
    let orderID: String
    let clientID: String
    let billingContact: ApplePayPaymentContact
    let shippingContact: ApplePayPaymentContact?
    let productFlow: String

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(token, forKey: .token)
        try container.encode(orderID, forKey: .orderID)
        try container.encode(clientID, forKey: .clientID)
        try container.encode(billingContact, forKey: .billingContact)
        if let shippingContact {
            try container.encode(shippingContact, forKey: .shippingContact)
        } else {
            try container.encodeNil(forKey: .shippingContact)
        }
        try container.encode(productFlow, forKey: .productFlow)
    }

    private enum CodingKeys: String, CodingKey {
        case token
        case orderID
        case clientID
        case billingContact
        case shippingContact
        case productFlow
    }
}

struct GraphQLEnvelope<T: Decodable>: Decodable {

    let data: T?
    let errors: [GraphQLFailure]?
}

struct GraphQLFailure: Decodable {

    let message: String
}

struct ApplePayConfigEnvelope: Decodable {

    let applepayConfig: ApplePayConfig?
}

struct ApproveApplePayEnvelope: Decodable {

    let approveApplePayPayment: JSONValue
}
