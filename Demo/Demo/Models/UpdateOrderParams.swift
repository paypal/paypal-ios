class UpdateOrderParams {
    
    let orderID: String
    let updateOperations: [UpdateOrderOperation]
    
    init(orderID: String, shippingMethods: [ShippingOption]?, amount: Amount) {
        self.orderID = orderID
        self.updateOperations = [
            UpdateOrderOperation(
                operation: "replace",
                path: "/purchase_units/@reference_id=='default'/amount",
                value: amount
            ),
            UpdateOrderOperation(
                operation: "replace",
                path: "/purchase_units/@reference_id=='default'/shipping/options",
                value: shippingMethods
            )
        ]
    }
}

class UpdateOrderOperation: Encodable {
    
    private enum CodingKeys: String, CodingKey {
        case operation = "op"
        case path
        case value
    }

    let operation: String
    let referenceId: String?
    let path: String
    let value: PatchableValue?
    
    init(
        operation: String,
        path: String,
        referenceId: String? = nil,
        value: Encodable? = nil
    ) {
        self.operation = operation
        self.referenceId = referenceId
        self.path = path

        if let value = value {
            self.value = PatchableValue(value: value)
        } else {
            self.value = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(operation, forKey: .operation)
        try container.encode(path, forKey: .path)
        try container.encodeIfPresent(value, forKey: .value)
    }
}

struct PatchableValue: Encodable {
    
    let value: Encodable

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
