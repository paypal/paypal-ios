// Delegate used to start the PayPal flow and perform any other aditional actions needed
public protocol PaymentButtonDelegate: AnyObject {
    func paymentButtonTapped()
}
