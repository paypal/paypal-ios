import UIKit
import CorePayments
import AuthenticationServices

class FeatureBaseViewController: UIViewController {

    // MARK: - View Spacing

    enum Constants {
        static let stackViewSpacing: CGFloat = 16
        static let layoutSpacing: CGFloat = 16
        static let textFieldHeight: CGFloat = 40
    }

    // MARK: - UI Components

    lazy var createOrderStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var amountTextField: CustomTextField = {
        let textField = CustomTextField(placeholderText: "Amount", defaultValue: "10.00")
        textField.keyboardType = .decimalPad
        return textField
    }()

    lazy var createOrderButton: CustomButton = {
        let createOrderButton = CustomButton(title: "Create Order")
        createOrderButton.addTarget(self, action: #selector(createOrderTapped), for: .touchUpInside)
        return createOrderButton
    }()

    lazy var bottomStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let baseViewModel: BaseViewModel

    // MARK: - Initialization

    init(baseViewModel: BaseViewModel) {
        self.baseViewModel = baseViewModel
        super.init(nibName: nil, bundle: nil)
        baseViewModel.view = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle & UI Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBottomView()
        baseViewModel.updateTitle("Tap create order to begin")
    }

    func configureBottomView() {
        view.addSubview(createOrderStackView)
        createOrderStackView.addArrangedSubview(amountTextField)
        createOrderStackView.addArrangedSubview(createOrderButton)
        view.addSubview(bottomStatusLabel)

        NSLayoutConstraint.activate([
            createOrderStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.layoutSpacing),
            createOrderStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: Constants.layoutSpacing
            ),
            createOrderStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -Constants.layoutSpacing
            ),

            amountTextField.heightAnchor.constraint(equalToConstant: Constants.textFieldHeight),

            bottomStatusLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomStatusLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.layoutSpacing)
        ])
    }

    // MARK: - Create Order implementation

    @objc func createOrderTapped() {
        Task {
            await baseViewModel.createOrder(
                amount: amountTextField.text, selectedMerchantIntegration: baseViewModel.selectedMerchantIntegration
            )
        }
    }
}
