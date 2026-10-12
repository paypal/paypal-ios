import PassKit

enum ApplePayPaymentRequestBuilder {

    static let contactFields: Set<PKContactField> = [.name, .postalAddress, .emailAddress, .phoneNumber]

    static func make(request: ApplePayRequest, config: ApplePayConfig) throws -> PKPaymentRequest {
        let networks = config.supportedNetworks.compactMap(network(named:))
        guard !networks.isEmpty else {
            throw ApplePayError.noSupportedNetworks
        }

        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = request.merchantIdentifier
        paymentRequest.countryCode = config.merchantCountry
        paymentRequest.currencyCode = request.currencyCode
        paymentRequest.supportedNetworks = networks
        paymentRequest.merchantCapabilities = capabilities(from: config.merchantCapabilities)
        paymentRequest.paymentSummaryItems = summaryItems(total: request.total, lineItems: request.lineItems)
        if request.requiresBillingContact {
            paymentRequest.requiredBillingContactFields = contactFields
        }
        if request.requiresShippingContact {
            paymentRequest.requiredShippingContactFields = contactFields
        }
        return paymentRequest
    }

    static func network(named name: String) -> PKPaymentNetwork? {
        let key = name.lowercased() == "americanexpress" ? "amex" : name.lowercased()
        let alias = key == "unionpay" ? "chinaunionpay" : key
        return networks[alias]
    }

    private static let networks: [String: PKPaymentNetwork] = [
        "visa": .visa,
        "mastercard": .masterCard,
        "amex": .amex,
        "discover": .discover,
        "maestro": .maestro,
        "electron": .electron,
        "interac": .interac,
        "jcb": .JCB,
        "elo": .elo,
        "chinaunionpay": .chinaUnionPay,
        "cartesbancaires": .cartesBancaires,
        "girocard": .girocard,
        "vpay": .vPay,
        "mada": .mada,
        "eftpos": .eftpos,
        "dankort": .dankort
    ]

    private static func capabilities(from names: [String]) -> PKMerchantCapability {
        var capabilities: PKMerchantCapability = []
        for name in names {
            switch name.lowercased() {
            case "supports3ds":
                capabilities.insert(.threeDSecure)
            case "supportscredit":
                capabilities.insert(.credit)
            case "supportsdebit":
                capabilities.insert(.debit)
            case "supportsemv":
                capabilities.insert(.emv)
            default:
                continue
            }
        }
        return capabilities.isEmpty ? .threeDSecure : capabilities
    }

    private static func summaryItems(
        total: ApplePaySummaryItem,
        lineItems: [ApplePaySummaryItem]
    ) -> [PKPaymentSummaryItem] {
        (lineItems + [total]).map { item in
            PKPaymentSummaryItem(
                label: item.label,
                amount: NSDecimalNumber(decimal: item.amount),
                type: item.kind == .pending ? .pending : .final
            )
        }
    }
}
