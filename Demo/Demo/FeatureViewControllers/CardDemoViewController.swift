import UIKit

class CardDemoViewController: FeatureBaseViewController, UITextFieldDelegate {

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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        /// Ensures that only numbers are entered into our text fields
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }

        guard let cardNumber = cardNumberTextField.text, let expirationDate = expirationTextField.text, let cvv = cvvTextField.text
        else { return true }

        /// Get full string by appending the current text field with the new characters
        guard let current = textField.text else { return true }
        guard let changedRange = Range(range, in: current) else { return true }
        let new = current.replacingCharacters(in: changedRange, with: string)

        /// Format text field based on the card type
        if textField == cardNumberTextField {
            /// clean the text field test to remove spaces
            let cleanedText = new.replacingOccurrences(of: " ", with: "")

            /// check that the count of the text field is less than or equal to the card types max length
            guard cleanedText.count <= CardType.unknown.getCardType(cleanedText).maxLength else {
                return false
            }

            textField.text = cardFormatter.formatCardNumber(cleanedText)
            toggleButton(cardNumber: textField.text ?? "", expirationDate: expirationDate, cvv: cvv)

            // WIP: Adjust cursor
            if string.isEmpty {
                let location = textField.position(from: textField.beginningOfDocument, offset: range.location) ?? textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: location, to: location)
            } else {
                let offset = (textField.text ?? "").count - cardNumber.count
                let location = textField.position(from: textField.beginningOfDocument, offset: range.location + offset) ?? textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: location, to: location)
            }
            // End WIP

            return false
        /// format expiration date text field
        } else if textField == expirationTextField {
            /// clean the text field text to remove slash and spaces
            let cleanedText = new.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")

            /// limit expiration date to 4 characters max
            guard cleanedText.count <= 4 else {
                return false
            }

            textField.text = cardFormatter.formatExpirationDate(cleanedText)
            toggleButton(cardNumber: cardNumber, expirationDate: textField.text ?? "", cvv: cvv)
            return false
        } else if textField == cvvTextField {
            /// Limit cvv character count to be 4 characters max
            guard new.count <= 4 else {
                return false
            }

            textField.text = new
            toggleButton(cardNumber: cardNumber, expirationDate: expirationDate, cvv: textField.text ?? "")
            return false
        }
        return true
    }

    @objc func didTapPayButton() {
        updateTitle("Processing order...")
        payButton.startAnimating()
        // TODO: Call `processOrder` and `payButton.stopAnimating()` once process order is complete
    }

    private func toggleButton(cardNumber: String, expirationDate: String, cvv: String) {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        payButton.isEnabled = enabled
    }
}
