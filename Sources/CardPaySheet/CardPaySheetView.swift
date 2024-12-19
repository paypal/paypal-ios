import SwiftUI
#if canImport(CardPayments)
import CardPayments
#endif
#if canImport(CorePayments)
import CorePayments
#endif

public struct CardPaySheetView: UIViewControllerRepresentable {
    
    private let cardPaySheet: CardPaySheet
    private let orderID: String
    private let sca: SCA
    private let completion: (Result<CardResult, Error>) -> Void

    public init(
        config: CoreConfig,
        orderID: String,
        sca: SCA = .scaWhenRequired,
        completion: @escaping (Result<CardResult, Error>) -> Void
    ) {
        self.cardPaySheet = CardPaySheet(config: config, orderID: orderID, sca: sca)
        self.orderID = orderID
        self.sca = sca
        self.completion = completion
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        return cardPaySheet.createCardFormViewController(orderID: orderID, sca: sca, completion: completion)
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
