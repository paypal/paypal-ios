import UIKit
#if canImport(CardPayments)
import CardPayments
#endif

class CardFormViewController: UIViewController {

    private let cardForm = CardForm()
    private let cardClient: CardClient
    private let orderID: String
    private let sca: SCA
    private let completion: (Result<CardResult, Error>) -> Void
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleContinueButton), for: .touchUpInside)

        button.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var isLoading = false {
        didSet {
            updateButtonState()
        }
    }

    private func updateButtonState() {
        continueButton.isEnabled = !isLoading
        if isLoading {
            continueButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            continueButton.setTitle("Continue", for: .normal)
            activityIndicator.stopAnimating()
        }
    }

    init(cardClient: CardClient, orderID: String, sca: SCA, completion: @escaping (Result<CardResult, Error>) -> Void) {
        self.cardClient = cardClient
        self.orderID = orderID
        self.completion = completion
        self.sca = sca
        super.init(nibName: nil, bundle: nil)

        self.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = self.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 12
            }
        } else {
            // Fallback on earlier versions
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            if let sheet = sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 12
            }
        } else {
            // Fallback on earlier versions
        }
        setupViews()
    }

    private func setupViews() {
        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [cardForm, continueButton])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 24, right: 24)

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(dismissForm)
        )
    }

    @objc private func dismissForm() {
        dismiss(animated: true)
    }

    @objc private func handleContinueButton() {
        let card = Card.createCard(
            cardNumber: cardForm.cardNumber ?? "",
            expirationDate: cardForm.expiryDate ?? "",
            cvv: cardForm.cvv ?? ""
        )

        let request = CardRequest(
            orderID: orderID,
            card: card,
            sca: sca
        )

        isLoading = true

        Task {
            do {
                let result = try await cardClient.approveOrder(request: request)
                completion(.success(result))
                await MainActor.run {
                    isLoading = false
                    self.dismiss(animated: true)
                }
            } catch {
                isLoading = false
                completion(.failure(error))
            }
        }
    }
}

extension Card {

    static func createCard(cardNumber: String, expirationDate: String, cvv: String) -> Card {
        let cleanedCardText = cardNumber.replacingOccurrences(of: " ", with: "")

        let expirationComponents = expirationDate.components(separatedBy: " / ")
        let expirationMonth = expirationComponents[0]
        let expirationYear = "20" + expirationComponents[1]

        return Card(number: cleanedCardText, expirationMonth: expirationMonth, expirationYear: expirationYear, securityCode: cvv)
    }

    static func isCardFormValid(cardNumber: String, expirationDate: String, cvv: String) -> Bool {
        let cleanedCardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        let cleanedExpirationDate = expirationDate.replacingOccurrences(of: " / ", with: "")

        let enabled = cleanedCardNumber.count >= 15 && cleanedCardNumber.count <= 19
        && cleanedExpirationDate.count == 4 && cvv.count >= 3 && cvv.count <= 4
        return enabled
    }
}
