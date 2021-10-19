import UIKit
import PaymentsCore
import Card

class CardDemoViewController: FeatureBaseViewController, UITextFieldDelegate {

    // MARK: - PayPal SDK Setup

    let coreConfig = CoreConfig(
        clientID: DemoSettings.clientID,
        environment: DemoSettings.environment.paypalSDKEnvironment
    )

    lazy var cardClient: CardClient = {
        CardClient(config: coreConfig)
    }()

    // MARK: - UI Components

    typealias Constants = FeatureBaseViewController.Constants

    let cardFormStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    let expirationCVVStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var cardNumberTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Card Number")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var expirationTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Expiration")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var cvvTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "CVV")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var payButton: CustomButton = {
        let payButton = CustomButton(title: "\(DemoSettings.intent.rawValue.capitalized) Order")
        payButton.addTarget(self, action: #selector(didTapPayButton), for: .touchUpInside)
        payButton.layer.cornerRadius = 8
        payButton.backgroundColor = .systemBlue
        payButton.tintColor = .white
        payButton.isEnabled = false
        return payButton
    }()

    private let cardFormatter = CardFormatter()

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        cardNumberTextField.delegate = self
        expirationTextField.delegate = self
        cvvTextField.delegate = self

        addSubviews()
        setupConstraints()
    }

    func addSubviews() {
        view.addSubview(cardFormStackView)

        cardFormStackView.addArrangedSubview(cardNumberTextField)
        cardFormStackView.addArrangedSubview(expirationCVVStackView)
        cardFormStackView.addArrangedSubview(payButton)

        expirationCVVStackView.addArrangedSubview(expirationTextField)
        expirationCVVStackView.addArrangedSubview(cvvTextField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            cardFormStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardFormStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            cardFormStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),

            cardNumberTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            expirationTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            cvvTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            payButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    // MARK: - FeatureBaseViewController Override

    /// Allows us to only enable the pay button once all fields are filled out and we have an order ID
    override func createOrderTapped(completion: @escaping () -> Void = {}) {
        super.createOrderTapped {
            DispatchQueue.main.async {
                self.enableButton(
                    cardNumber: self.cardNumberTextField.text ?? "",
                    expirationDate: self.expirationTextField.text ?? "",
                    cvv: self.cvvTextField.text ?? ""
                )
            }
        }
    }

    // MARK: - Card Module Integration

    @objc func didTapPayButton() {
        updateTitle("Approving order...")
        payButton.startAnimating()

        guard let card = createCard(),
            let orderID = orderID else {
            updateTitle("Failed: missing card / orderID.")
            return
        }

        cardClient.approveOrder(orderID: orderID, card: card) { result in
            switch result {
            case .success(let orderData):
                if let orderStatus = orderData.status {
                    self.updateTitle("\(DemoSettings.intent.rawValue.capitalized) status: \(orderStatus.rawValue)")
                }
                self.processOrder(orderData: orderData) {
                    self.payButton.stopAnimating()
                }
            case .failure(let error):
                self.updateTitle("\(DemoSettings.intent) failed: \(error.localizedDescription)")
                self.payButton.stopAnimating()
            }
        }
    }

    private func createCard() -> Card? {
        guard let cardNumber = cardNumberTextField.text,
            let cvv = cvvTextField.text,
            let expirationDate = expirationTextField.text else {
            return nil
        }

        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }

    // MARK: - Card Field Formatting

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// Ensures that only numbers are entered into our text fields
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        /// Holder for the text fields to avoid unwrapping when toggling the button
        guard let cardNumber = cardNumberTextField.text, let expirationDate = expirationTextField.text, let cvv = cvvTextField.text else {
            return true
        }

        /// Get full string by appending the current text field with the new characters
        guard let current = textField.text else { return true }
        guard let changedRange = Range(range, in: current) else { return true }
        let new = current.replacingCharacters(in: changedRange, with: string)

        if textField == cardNumberTextField {
            formatCardNumber(textField: textField, newString: new)
            enableButton(cardNumber: textField.text ?? "", expirationDate: expirationDate, cvv: cvv)
            setCursorLocation(textField: textField, range: range)
            return false
        } else if textField == expirationTextField {
            formatExpirationDate(textField: textField, newString: new)
            enableButton(cardNumber: cardNumber, expirationDate: textField.text ?? "", cvv: cvv)
            setCursorLocation(textField: textField, range: range)
            return false
        } else if textField == cvvTextField {
            /// Limit cvv character count to be 4 characters max
            guard new.count <= 4 else { return false }
            textField.text = new
            enableButton(cardNumber: cardNumber, expirationDate: expirationDate, cvv: textField.text ?? "")
            return false
        }
        return true
    }

    private func formatCardNumber(textField: UITextField, newString: String) {
        /// clean the text field test to remove spaces
        let cleanedText = newString.replacingOccurrences(of: " ", with: "")

        /// check that the count of the text field is less than or equal to the card types max length
        guard cleanedText.count <= CardType.unknown.getCardType(cleanedText).maxLength else { return }

        textField.text = cardFormatter.formatCardNumber(cleanedText)
    }

    private func formatExpirationDate(textField: UITextField, newString: String) {
        /// clean the text field text to remove slash and spaces
        let cleanedText = newString.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")

        /// limit expiration date to 4 characters max
        guard cleanedText.count <= 4 else { return }

        textField.text = cardFormatter.formatExpirationDate(cleanedText)
    }

    private func setCursorLocation(textField: UITextField, range: NSRange) {
        guard let text = textField.text else { return }
        /// Holders for the cursor positions
        let positionOriginal = textField.beginningOfDocument
        let cursorLocation = textField.position(from: positionOriginal, offset: (range.location + NSString(string: text).length))

        if let cursorLocation = cursorLocation {
            textField.selectedTextRange = textField.textRange(from: cursorLocation, to: cursorLocation)
        }
    }

    private func enableButton(cardNumber: String, expirationDate: String, cvv: String) {
        guard orderID != nil else {
            updateTitle("Create an order to proceed")
            payButton.isEnabled = false
            return
        }

        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        payButton.isEnabled = enabled
    }
}
