import UIKit
#if canImport(CorePayments)
import CorePayments
#endif

// swiftlint:disable type_body_length
/// Handles functionality shared across payment buttons
public class PaymentButton: UIButton {

    // asset identifier path for image and color button assets
    #if SWIFT_PACKAGE
    static let bundle = Bundle.module
    #elseif COCOAPODS
    static let bundle: Bundle = {
        let frameworkBundle = Bundle(for: PaymentButton.self)
        if let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("PayPalSDK.bundle") {
            if let bundle = Bundle(url: bundleURL) {
                return bundle
            }
        }
        return frameworkBundle
    }()
    #else
    static let bundle = Bundle(for: PaymentButton.self)
    #endif

    // Use an empty config and default to live environment for button analytics
    private let analyticsService = AnalyticsService(
        coreConfig: .init(clientID: "N/A", environment: .live),
        orderID: "N/A"
    )

    // MARK: - Init

    required init(
        fundingSource: PaymentButtonFundingSource,
        color: PaymentButtonColor,
        edges: PaymentButtonEdges,
        size: PaymentButtonSize,
        insets: NSDirectionalEdgeInsets?,
        label: PaymentButtonLabel?
    ) {
        self.fundingSource = fundingSource
        self.color = color
        self.edges = edges
        self.size = size
        self.insets = insets
        self.label = label
        self.analyticsService.sendEvent("payment-button:initialized", buttonType: fundingSource.rawValue)
        super.init(frame: .zero)
        UIFont.registerFont()
        customizeAppearance()
        self.addTarget(self, action: #selector(onTap), for: .touchUpInside)
    }

    // MARK: - Views

    let containerView: UIView = {
        let view = UIView(frame: .zero)
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var containerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [stackView])
        view.axis = .vertical
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(
            arrangedSubviews: [
                prefixLabel,
                configureLogo(),
                suffixLabel
            ]
        )
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.alignment = .center
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()

    private let prefixLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 1
        view.textAlignment = .center
        return view
    }()

    private let suffixLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 1
        view.textAlignment = .left
        return view
    }()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Attributes

    /// The type of the button's funding source (e.g. PayPal, Pay Later, Credit)
    public private(set) var fundingSource: PaymentButtonFundingSource

    /// The color of the button
    public private(set) var color: PaymentButtonColor

    /// The corners of the button and how they should be shaped.
    public private(set) var edges: PaymentButtonEdges

    /// The size enum determines how the button will be shown.
    public private(set) var size: PaymentButtonSize

    /// The padding on the smart payment button.
    public private(set) var insets: NSDirectionalEdgeInsets?

    /// The label displayed next to the button's logo.
    public private(set) var label: PaymentButtonLabel?

    private var imageHeight: CGFloat {
        // For pay later or paypal credit return different image height
        switch size {
        case .mini:
            return fundingSource == .payLater || fundingSource == .credit ? 12 : 24

        case .collapsed:
            return 15.0

        case .expanded:
            return 20.0

        case .full:
            return 26.0
        }
    }

    private var supportsPrefixLabel: Bool {
        switch size {
        case .mini, .collapsed:
            return false

        case .expanded, .full:
            if let label = label {
                return label.position == .prefix
            }
            return false
        }
    }

    private var supportsSuffixLabel: Bool {
        if fundingSource == .payLater {
            return true
        }

        switch size {
        case .mini, .collapsed:
            return false

        case .expanded, .full:
            if let label = label {
                return label.position == .suffix
            }
            return false
        }
    }

    // MARK: - Private

    @objc private func onTap() {
        analyticsService.sendEvent("payment-button:tapped", buttonType: fundingSource.rawValue)
    }

    // MARK: - Configuration

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        configureStackView()
        configureBackgroundColor()
        configurePrefix()
        configureSuffix()
        configureSubviews()
        configureConstraints()
        configureAccessibilityLabel()
    }

    private func configureStackView() {
        stackView.directionalLayoutMargins = insets ?? size.elementPadding
        stackView.spacing = size.elementSpacing
    }

    private func configureBackgroundColor() {
        backgroundColor = .clear
        containerView.backgroundColor = color.color
    }

    private func configureLogo() -> UIImageView {
        let logo = resize(with: image)
        let logoImageView = UIImageView(image: logo)
        sizeToImage(on: logoImageView, with: size)
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }

    private func configurePrefix() {
        prefixLabel.textColor = color.fontColor
        if let label = label, label.position == .prefix {
            prefixLabel.text = label.rawValue
        }
        prefixLabel.font = size.font
        prefixLabel.isHidden = !supportsPrefixLabel
    }

    private func configureSuffix() {
        suffixLabel.textColor = color.fontColor
        if let label = label, label.position == .suffix {
            suffixLabel.text = label.rawValue
        }
        suffixLabel.font = size.font
        suffixLabel.isHidden = !supportsSuffixLabel
    }
    
    private func configureAccessibilityLabel() {
        if let prefixText = prefixLabel.text, supportsPrefixLabel {
            accessibilityLabel = "\(prefixText) \(imageAccessibilityLabel)"
        } else if let suffixText = suffixLabel.text, supportsSuffixLabel {
            accessibilityLabel = "\(imageAccessibilityLabel) \(suffixText)"
        } else {
            accessibilityLabel = imageAccessibilityLabel
        }
    }

    private func configureSubviews() {
        containerView.addSubview(containerStackView)
        addSubview(containerView)
    }

    private func configureConstraints() {

        NSLayoutConstraint.activate(
            [
                containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
                containerView.topAnchor.constraint(equalTo: topAnchor),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )

        // Center stack view
        NSLayoutConstraint.activate(
            [
                containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ]
        )
    }

    // MARK: - Override Function
    override public func layoutSubviews() {
        super.layoutSubviews()
        configure()

        if size == .mini {
            let minValue = min(containerView.bounds.width, containerView.bounds.height)
            containerView.layer.cornerRadius = minValue / 2
        } else {
            containerView.layer.cornerRadius = edges.cornerRadius(for: containerView)
        }
    }

    public override var intrinsicContentSize: CGSize {
        switch size {
        case .mini:
            return CGSize(width: 36, height: 24)

        case .collapsed, .expanded, .full:
            return CGSize(width: frame.size.width, height: imageHeight + size.elementPadding.top * 2)
        }
    }

    // MARK: - Utility

    private func sizeToImage(on imageView: UIImageView, with size: PaymentButtonSize) {

        guard let image = imageView.image else { return }

        // Size to fit
        switch size {
        case .mini:
            let maxValue = max(image.size.width, image.size.height)
            imageView.bounds = CGRect(
                x: 0,
                y: 0,
                width: maxValue,
                height: maxValue
            )

        default:
            imageView.bounds = CGRect(
                x: 0,
                y: 0,
                width: image.size.width,
                height: image.size.height
            )
        }
    }

    private func resize(with image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        guard imageHeight != image.size.height else { return image }
        let aspectRatio = imageHeight / image.size.height
        return resize(
            image: image,
            to: CGSize(
                width: image.size.width * aspectRatio,
                height: image.size.height * aspectRatio
            )
        )
    }

    private func resize(image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        image.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    private func customizeAppearance() {
        containerView.layer.borderColor = color == .white ? UIColor.black.cgColor : UIColor.clear.cgColor
        containerView.layer.borderWidth = color == .white ? 1 : 0
    }
}
