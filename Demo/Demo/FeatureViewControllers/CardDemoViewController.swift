import UIKit

class CardDemoViewController: FeatureBaseViewController {

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
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var expirationTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Expiration")
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var cvvTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "CVV")
        textField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
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

    @objc func didTapPayButton() {
        updateTitle("Processing order...")
        payButton.startAnimating()
        // TODO: Call `processOrder` and `payButton.stopAnimating()` once process order is complete
        }

    @objc private func editingChanged() {
        cardNumberTextField.text = cardFormatter.formatCardNumber(cardNumberTextField.text ?? "")
        expirationTextField.text = cardFormatter.formatExpirationDate(expirationTextField.text ?? "")

        guard
            let cardNumberCount = cardNumberTextField.text?.count,
            let expirationDateCount = expirationTextField.text?.count,
            let cvvCount = cvvTextField.text?.count,
            cardNumberCount >= 18 && cardNumberCount <= 19,
            expirationDateCount >= 7 && expirationDateCount <= 9,
            cvvCount >= 3 && cvvCount <= 4
        else {
            payButton.isEnabled = false
            return
        }
        payButton.isEnabled = true
    }
}
