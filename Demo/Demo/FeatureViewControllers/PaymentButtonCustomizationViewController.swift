//
//  PaymentButtonCustomizationViewController.swift
//  Demo
//
//  Created by Jose Noriega on 25/05/2022.
//

import UIKit
import PayPalUI

class PaymentButtonCustomizationViewController: UIViewController {


    // MARK: - Views

    /// Scroll view which will auto size
    let scrollView = UIScrollView(frame: .zero)

    lazy var paymentButton: PaymentButton = setupPaymentButton()

    lazy var spbFundingPicker: UISegmentedControl = {
        let segment = UISegmentedControl(
            items: PaymentButtonFundingSource.allCases.map { $0.rawValue }
        )
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(reloadSmartPaymentButton), for: .valueChanged)
        return segment
    }()

    lazy var spbColorPicker: UISegmentedControl = {
        let segment = UISegmentedControl(items: [])
        segment.addTarget(self, action: #selector(reloadSmartPaymentButton), for: .valueChanged)
        return segment
    }()

    lazy var spbEdgesPicker: UISegmentedControl = {
        let segment = UISegmentedControl(
            items: PaymentButtonEdges.allCases.map { $0.description }
        )
        segment.selectedSegmentIndex = 1
        segment.addTarget(self, action: #selector(reloadSmartPaymentButton), for: .valueChanged)
        return segment
    }()

    lazy var spbSizePicker: UISegmentedControl = {
        let segment = UISegmentedControl(
            items: PaymentButtonSize.allCases.map { $0.description }
        )
        segment.selectedSegmentIndex = 1
        segment.addTarget(self, action: #selector(reloadSmartPaymentButton), for: .valueChanged)
        return segment
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                label("SmartPaymentButton Configuration"),
                spbFundingPicker,
                spbColorPicker,
                spbEdgesPicker,
                spbSizePicker
            ]
        )
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16.0
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: 16.0,
            left: 16.0,
            bottom: 16.0,
            right: 16.0
        )
        return stackView
    }()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
        configure()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Initialization

    private func configure() {
        // Add subviews
        scrollView.addSubview(stackView)
        view.addSubview(scrollView)

        view.backgroundColor = .white

        // Add constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints())

        stackView.addArrangedSubview(paymentButton)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadColorPicker()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Constraints

    // In order to self size scroll view, constraint UIScrollView to all four corners
    // of parent view constraint, then stackView to top bottom sides of parent scroll view
    // content layout guide, centerX of scrollView and set width and height equal
    // to frame layout guide. Ensure that stack view height constraint has a low priority.
    private func constraints() -> [NSLayoutConstraint] {
        let stackViewHeight = stackView.heightAnchor.constraint(
            equalTo: scrollView.frameLayoutGuide.heightAnchor
        )
        stackViewHeight.priority = .defaultLow
        return [
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackViewHeight,
            stackView.widthAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.widthAnchor
            ),
            stackView.leadingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.leadingAnchor
            ),
            stackView.trailingAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.trailingAnchor
            ),
            stackView.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            stackView.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            )
        ]
    }

    // MARK: - Target / Actions

    @objc private func reloadSmartPaymentButton(_ sender: UISegmentedControl) {
        if sender == spbFundingPicker {
            reloadColorPicker()
        }
        paymentButton.removeFromSuperview()

        paymentButton = setupPaymentButton()
        stackView.addArrangedSubview(paymentButton)
    }

    func setShadow(
        on button: PaymentButton,
        color: UIColor = .black,
        offset: CGSize = CGSize(width: 0, height: 1),
        opacity: Float = 0.3,
        radius: CGFloat = 1.0
    ) {
        button.layer.shadowOpacity = opacity
        button.layer.shadowRadius = radius
        button.layer.shadowOffset = offset
        button.layer.shadowColor = color.cgColor
    }

    private func reloadColorPicker() {
        let funding = PaymentButtonFundingSource.allCases[spbFundingPicker.selectedSegmentIndex]
        let segments = colorPickerSegments(with: funding)

        spbColorPicker.removeAllSegments()
        for segment in segments {
            spbColorPicker.insertSegment(
                withTitle: segment,
                at: spbColorPicker.numberOfSegments,
                animated: false
            )
        }
        spbColorPicker.selectedSegmentIndex = 0
    }

    private func colorPickerSegments(with funding: PaymentButtonFundingSource) -> [String] {
        switch funding {
        case .payPal:
            return PayPalButton.Color.allCases.map { $0.rawValue }

        case .payLater:
            return PayPalPayLaterButton.Color.allCases.map { $0.rawValue }

        case .credit:
            return PayPalCreditButton.Color.allCases.map { $0.rawValue }
        }
    }

    private func setupPaymentButton() -> PaymentButton {
        let fundingSource = PaymentButtonFundingSource.allCases[spbFundingPicker.selectedSegmentIndex]
        let edges = PaymentButtonEdges.allCases[spbEdgesPicker.selectedSegmentIndex]
        let size = PaymentButtonSize.allCases[spbSizePicker.selectedSegmentIndex]

        let paymentButton: PaymentButton

        switch fundingSource {
        case .payPal:
            let color = PayPalButton.Color.allCases[spbColorPicker.selectedSegmentIndex]
            paymentButton = PayPalButton(color: color, edges: edges, size: size)

        case .payLater:
            let color = PayPalPayLaterButton.Color.allCases[spbColorPicker.selectedSegmentIndex]
            paymentButton = PayPalPayLaterButton(color: color, edges: edges, size: size)

        case .credit:
            let color = PayPalCreditButton.Color.allCases[spbColorPicker.selectedSegmentIndex]
            paymentButton = PayPalCreditButton(color: color, edges: edges, size: size)
        }

        setShadow(on: paymentButton)
        return paymentButton
    }
}
