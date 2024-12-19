import UIKit

public class CardForm: UIView {

    private let cardFormatter = CardFormatter()

    private let cardInfoTitle: UILabel = {
        let label = UILabel()
        label.text = "Card Information"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private let countryRegionTitle: UILabel = {
        let label = UILabel()
        label.text = "Country or Region"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()

    private let cardNumberField: UITextField = {
        let field = UITextField()
        field.placeholder = "Card number"
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 8
        field.keyboardType = .numberPad
        return field
    }()

    private let expiryDateField: UITextField = {
        let field = UITextField()
        field.placeholder = "MM/YY"
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 8
        field.keyboardType = .numberPad
        return field
    }()

    private let cvvField: UITextField = {
        let field = UITextField()
        field.placeholder = "CVV"
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 8
        field.keyboardType = .numberPad
        field.isSecureTextEntry = true
        return field
    }()

    private let countryRegionField: UITextField = {
        let field = UITextField()
        field.placeholder = "United States"
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 8
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 8
        return field
    }()

    private let zipField: UITextField = {
        let field = UITextField()
        field.placeholder = "ZIP"
        field.borderStyle = .roundedRect
        field.backgroundColor = .systemBackground
        field.layer.borderColor = UIColor.systemGray5.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 8
        return field
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(
            arrangedSubviews:
                [cardInfoTitle, cardNumberField, expiryDateField, cvvField, countryRegionTitle, countryRegionField, zipField]
        )
        stack.axis = .vertical
        stack.spacing = 12
        stack.distribution = .fill
        return stack
    }()

    public var cardNumber: String? { cardNumberField.text?.replacingOccurrences(of: " ", with: "")}
    public var expiryDate: String? { expiryDateField.text }
    public var cvv: String? { cvvField.text }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTextFieldDelegates()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupTextFieldDelegates()
    }

    private func setupTextFieldDelegates() {
        cardNumberField.addTarget(self, action: #selector(cardNumberDidChange), for: .editingChanged)
        expiryDateField.addTarget(self, action: #selector(expiryDidChange), for: .editingChanged)
        cvvField.addTarget(self, action: #selector(cvvDidChange), for: .editingChanged)
    }

    @objc private func cardNumberDidChange(_ textField: UITextField) {
        if let text = textField.text {
            textField.text = cardFormatter.formatFieldWith(text, field: .cardNumber)
        }
    }

    @objc private func expiryDidChange(_ textField: UITextField) {
        if let text = textField.text {
            textField.text = cardFormatter.formatFieldWith(text, field: .expirationDate)
        }
    }

    @objc private func cvvDidChange(_ textField: UITextField) {
        if let text = textField.text {
            textField.text = cardFormatter.formatFieldWith(text, field: .cvv)
        }
    }

    private func setupViews() {
        backgroundColor = .white

        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 12
        layer.masksToBounds = true

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
}
