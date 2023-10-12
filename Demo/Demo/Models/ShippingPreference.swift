enum ShippingPreference: String, CaseIterable, Identifiable {
    case noShipping = "NO_SHIPPING"
    case providedAddress = "SET_PROVIDED_ADDRESS"
    case getFromFile = "GET_FROM_FILE"

    var id: ShippingPreference { self }
}
