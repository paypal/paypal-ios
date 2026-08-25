// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayPal",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CorePayments",
            targets: ["CorePayments"]
        ),
        .library(
            name: "PaymentButtons",
            targets: ["PaymentButtons"]
        ),
        .library(
            name: "PayPalPayments",
            targets: ["PayPalPayments"]
        ),
        .library(
            name: "CardPayments",
            targets: ["CardPayments"]
        ),
        .library(
            name: "FraudProtection",
            targets: ["FraudProtection"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/paypal/paypal-risk-ios", exact: "5.6.0-beta2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CorePayments",
            dependencies: [],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "CardPayments",
            dependencies: ["CorePayments"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "PaymentButtons",
            dependencies: ["CorePayments"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "PayPalPayments",
            dependencies: ["CorePayments"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "FraudProtection",
            dependencies: [
                "CorePayments",
                .product(name: "PayPalRisk", package: "paypal-risk-ios")
            ],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
    ]
)
