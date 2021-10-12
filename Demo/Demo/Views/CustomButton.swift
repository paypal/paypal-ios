import UIKit

class CustomButton: UIButton {

    var titleHolder: String?

    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.white
        return activityIndicator
    }()

    convenience init(title: String) {
        self.init(type: .system)

        titleHolder = title

        setTitle(title, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel?.font = .preferredFont(forTextStyle: .body)
        titleLabel?.numberOfLines = 0
        titleLabel?.textAlignment = .center
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func startAnimating() {
        self.setTitle("", for: .normal)
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        self.setTitle(titleHolder, for: .normal)
        activityIndicator.stopAnimating()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
