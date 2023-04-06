/// :nodoc:
public struct GetOrderInfoResponse: Decodable {

    public let id, status, intent: String
    public let paymentSource: PaymentSource?
    public let purchaseUnits: [PurchaseUnit]?
    public let links: [Link]?
}

/// :nodoc:
public struct PurchaseUnit: Codable {

    public let amount: Amount
}

/// :nodoc:
public struct Amount: Codable {

    public let currencyCode: String
    public let value: String
}

/// :nodoc:
public struct Link: Decodable {

    public let href: String?
    public let rel, method: String?
}
