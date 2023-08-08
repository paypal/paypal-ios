struct SetupTokenDetailsResponse: Decodable {
    
    let id: String
    let status: String
    let links: [Link]
    let paymentSource: PaymentSource?
}
