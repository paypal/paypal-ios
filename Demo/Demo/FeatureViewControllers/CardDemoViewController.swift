import UIKit
import PaymentsCore
import PayPalNativeCheckout

class CardDemoViewController: FeatureBaseViewController, UITextFieldDelegate {

    // MARK: - UI Components

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

    lazy var checkoutButton: CustomButton = {
        let checkoutButton = CustomButton(title: "\(DemoSettings.intent.rawValue.capitalized) Order")
        checkoutButton.addTarget(self, action: #selector(didTapCheckoutButton), for: .touchUpInside)
        checkoutButton.layer.cornerRadius = 8
        checkoutButton.backgroundColor = .systemBlue
        checkoutButton.tintColor = .white
        checkoutButton.isEnabled = false
        return checkoutButton
    }()

    // TODO: need to remove after final integration, this is just to verify
    lazy var eligibilityButton: CustomButton = {
        let eligibilityButton = CustomButton(title: "eligibility")
        eligibilityButton.addTarget(self, action: #selector(didTapEligibilityButton), for: .touchUpInside)
        eligibilityButton.layer.cornerRadius = 8
        eligibilityButton.backgroundColor = .systemBlue
        eligibilityButton.tintColor = .white
        return eligibilityButton
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
        cardFormStackView.addArrangedSubview(checkoutButton)
        cardFormStackView.addArrangedSubview(eligibilityButton)

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
            checkoutButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    // MARK: - FeatureBaseViewController Override

    /// Allows us to only enable the pay button once all fields are filled out and we have an order ID
    @objc override func createOrderTapped() {
        Task {
            _ = await baseViewModel.createOrder(amount: amountTextField.text)
            checkoutButton.isEnabled = baseViewModel.isCardFormValid(
                cardNumber: cardNumberTextField.text ?? "",
                expirationDate: expirationTextField.text ?? "",
                cvv: cvvTextField.text ?? ""
            )
        }
    }

    // MARK: - Card Module Integration

    @objc func didTapCheckoutButton() {
        baseViewModel.updateTitle("Approving order...")
        checkoutButton.startAnimating()

        guard let card = baseViewModel.createCard(
            cardNumber: cardNumberTextField.text,
            expirationDate: expirationTextField.text,
            cvv: cvvTextField.text
        ),
            let orderID = baseViewModel.orderID
        else {
            return
        }

        Task {
            await baseViewModel.checkoutWith(card: card, orderID: orderID, context: self)
            self.checkoutButton.stopAnimating()
        }
    }

    @objc func didTapEligibilityButton() {
        Task {
            try await baseViewModel.testEligibility()
        }
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

        switch textField {
        case cardNumberTextField:
            textField.text = cardFormatter.formatFieldWith(new, field: .cardNumber)
            checkoutButton.isEnabled = baseViewModel.isCardFormValid(
                cardNumber: textField.text ?? "",
                expirationDate: expirationDate,
                cvv: cvv
            )
            setCursorLocation(textField: textField, range: range)
            return false
        case expirationTextField:
            textField.text = cardFormatter.formatFieldWith(new, field: .expirationDate)
            checkoutButton.isEnabled = baseViewModel.isCardFormValid(cardNumber: cardNumber, expirationDate: textField.text ?? "", cvv: cvv)
            setCursorLocation(textField: textField, range: range)
            return false
        case cvvTextField:
            textField.text = cardFormatter.formatFieldWith(new, field: .cvv)
            checkoutButton.isEnabled = baseViewModel.isCardFormValid(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                cvv: textField.text ?? ""
            )
            return false
        default:
            return true
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss keyboard when the return key is typed into cvv text field
        // Ref: https://stackoverflow.com/a/38835275
        view.endEditing(true)
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
}
