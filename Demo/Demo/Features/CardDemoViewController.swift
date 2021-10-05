import UIKit

class CardDemoViewController: FeatureBaseViewController {
    // TODO: Validate card fields are filled out
    // TODO: Add proper spacing / styling / max characters to card fields
    // TODO: Animate pay button to indicate loading
    // TODO: Disable pay button until fields are filled out

    private enum Constants {
        static let stackViewSpacing: CGFloat = 16
        static let layoutSpacing: CGFloat = 16
        static let textFieldHeight: CGFloat = 40
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
        let payButton = button(
            title: "\(DemoSettings.intent.rawValue.capitalized) Order",
            action: #selector(didTapPayButton)
        )
        payButton.layer.cornerRadius = 8
        payButton.backgroundColor = .systemBlue
        payButton.tintColor = .white
        return payButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

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

            secondaryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            secondaryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),

            cardNumberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            cardNumberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            cardNumberTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            expirationTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),
            cvvTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            payButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.layoutSpacing),
            payButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.layoutSpacing),
            payButton.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight)
        ])
    }

    @objc func didTapPayButton() {
        updateTitle("Processing order...")
        // TODO: Call `processOrder`
    }
}
