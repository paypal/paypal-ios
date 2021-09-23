import UIKit
import Card
import PayPal
import InAppSettingsKit

class ViewController: UIViewController {

    private enum Constants {
        static let stackViewSpacing: CGFloat = 16
    }

    let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .center
        view.spacing = Constants.stackViewSpacing
        return view
    }()

    lazy var cardButton: UIButton = {
      let cardButton = UIButton()
        cardButton.setTitle("Checkout with Card", for: .normal)
        cardButton.layer.cornerRadius = 8
        cardButton.backgroundColor = .systemBlue
        cardButton.tintColor = .white
        cardButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        cardButton.addTarget(self, action: #selector(didTapCardButton), for: .touchUpInside)
        cardButton.translatesAutoresizingMaskIntoConstraints = false
      return cardButton
    }()

    lazy var paypalButton: UIButton = {
      let paypalButton = UIButton()
        paypalButton.setTitle("Checkout with PayPal", for: .normal)
        paypalButton.layer.cornerRadius = 8
        paypalButton.backgroundColor = .systemBlue
        paypalButton.tintColor = .white
        paypalButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        paypalButton.addTarget(self, action: #selector(didTapPayPalButton), for: .touchUpInside)
        paypalButton.translatesAutoresizingMaskIntoConstraints = false
      return paypalButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        if #available(iOS 15.0, *) {
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingsTapped))

        setupUI()
        setupConstraints()
    }

    @objc func settingsTapped() {
        let appSettingsViewController = IASKAppSettingsViewController()
        appSettingsViewController.showDoneButton = false
        navigationController?.pushViewController(appSettingsViewController, animated: true)
    }

    @objc func didTapCardButton() {
        let cardViewController = CardDemoViewController()
        cardViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(cardViewController, animated: true)
    }

    @objc func didTapPayPalButton() {
        let paypalViewController = PayPalDemoViewController()
        paypalViewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(paypalViewController, animated: true)
    }

    func setupUI() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(cardButton)
        stackView.addArrangedSubview(paypalButton)
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            cardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardButton.heightAnchor.constraint(equalToConstant: 40),

            paypalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            paypalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            paypalButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
}
