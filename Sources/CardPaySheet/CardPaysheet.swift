import UIKit
#if canImport(CardPayments)
import CardPayments
#endif
#if canImport(CorePayments)
import CorePayments
#endif

public class CardPaySheet {

    private let cardClient: CardClient
    private let orderID: String
    private let sca: SCA

    // need to pass in price info to display on pay button
    public init(config: CoreConfig, orderID: String, sca: SCA = .scaWhenRequired) {
        self.cardClient = CardClient(config: config)
        self.orderID = orderID
        self.sca = sca
    }

    func createCardFormViewController(
        orderID: String,
        sca: SCA,
        completion: @escaping (Result<CardResult, Error>) -> Void
    ) -> UIViewController {
        let cardFormVC = CardFormViewController(cardClient: cardClient, orderID: orderID, sca: sca, completion: completion)
        let nav = UINavigationController(rootViewController: cardFormVC)

        nav.modalPresentationStyle = .pageSheet

        if #available(iOS 15.0, *) {
            if let sheet = nav.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 12
            }
        } else {
            // Fallback
        }

        return nav
    }
}
