import UIKit

class CardDemoViewController: FeatureBaseViewController {
    // TODO: Validate card fields are filled out
    // TODO: Add proper spacing / styling / max characters to card fields
    // TODO: Animate pay button to indicate loading
    // TODO: Disable pay button until fields are filled out

    private enum Constants {
        static let stackViewSpacing: CGFloat = 16
    }

    let mainStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    let secondaryStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fillEqually
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var cardNumberTextField: UITextField = {
        let textField = textField(placeholder: "Card Number")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var expirationTextField: UITextField = {
        let textField = textField(placeholder: "Expiration")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var cvvTextField: UITextField = {
        let textField = textField(placeholder: "CVV")
        textField.keyboardType = .numberPad
        return textField
    }()

    lazy var payButton: UIButton = {
        let payButton = button(title: "Pay", action: #selector(didTapPayButton))
        payButton.layer.cornerRadius = 8
        payButton.backgroundColor = .systemBlue
        payButton.tintColor = .white
        return payButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        processOrder(paymentMethod: .card, state: .notStarted)
        setupUI()
        setupConstraints()
    }

    func setupUI() {
        view.addSubview(mainStackView)

        mainStackView.addArrangedSubview(cardNumberTextField)
        mainStackView.addArrangedSubview(secondaryStackView)
        mainStackView.addArrangedSubview(payButton)

        secondaryStackView.addArrangedSubview(expirationTextField)
        secondaryStackView.addArrangedSubview(cvvTextField)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            secondaryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            secondaryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            cardNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: 40),

            expirationTextField.heightAnchor.constraint(equalToConstant: 40),
            cvvTextField.heightAnchor.constraint(equalToConstant: 40),

            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            payButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func didTapPayButton() {
        // TODO: Pass card / order details into fetchOrderID
        processOrder(paymentMethod: .card, state: .orderProcessing)
        fetchOrderID(paymentMethod: .card)
    }
}
