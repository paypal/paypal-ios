import Foundation

struct DemoCard: Identifiable {

    let id = UUID()
    let title: String
    let numbers: [String]
    
    // source: https://developer.paypal.com/api/rest/sandbox/card-testing/#link-testcardnumbers
    static let allSections = [
        DemoCard(title: "Successful Authentication Visa", numbers: ["4868 7194 6070 7704"]),
        DemoCard(title: "Vault with Purchase (no 3DS)", numbers: ["4000 0000 0000 0002"]),
        DemoCard(title: "Step up", numbers: ["5314 6090 4083 0349"]),
        DemoCard(title: "Frictionless - LiabilityShift Possible", numbers: ["4005 5192 0000 0004"]),
        DemoCard(title: "Frictionless - LiabilityShift NO", numbers: ["4020 0278 5185 3235"]),
        DemoCard(title: "No Challenge", numbers: ["4111 1111 1111 1111"])
    ]
}
