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
        guard let cardNumber = cardNumberTextField.text, let expiry = expirationTextField.text, let cvv = cvvTextField.text
        else { return true }

        // Get new string
        guard let current = textField.text else { return true }
        guard let changedRange = Range(range, in: current) else { return true }
        let new = current.replacingCharacters(in: changedRange, with: string)

        // Format string
        if textField == cardNumberTextField {
            let cleanedText = cardNumberTextField.text?.replacingOccurrences(of: " ", with: "") ?? ""
            let currentCharacterCount = cleanedText.count
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= CardType.unknown.getCardType(cleanedText).maxLength
        } else if textField == expirationTextField {
            // Format expiration to MM / YY and limit character count

            let cleanedNew = new.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: " ", with: "")

            // Limit character count. This should be MMYY (4 characters max)
            guard cleanedNew.count <= 4 else {
                return false
            }

            // Set textField to be new string and format with " / "
            textField.text = cleanedNew
            if cleanedNew.count > 2 {
                textField.text?.insert(contentsOf: " / ", at: cleanedNew.index(cleanedNew.startIndex, offsetBy: 2))
            }

            // Enable/disable button
            toggleButton(cardNumber: cardNumber, expiry: cleanedNew, cvv: cvv)
            return false
        } else if textField == cvvTextField {
            // Limit cvv character count to be 4 characters max
            toggleButton(cardNumber: cardNumber, expiry: expiry, cvv: new)
            return new.count <= 4
        }
        return true
    }

    private func toggleButton(cardNumber: String, expiry: String, cvv: String) {
        // TODO: card number
        let enabled = expiry.count == 4 && cvv.count >= 3 && cvv.count <= 4
        payButton.isEnabled = enabled
    }

    @objc func didTapPayButton() {
        updateTitle("Processing order...")
        payButton.startAnimating()
        // TODO: Call `processOrder` and `payButton.stopAnimating()` once process order is complete
    }
}
