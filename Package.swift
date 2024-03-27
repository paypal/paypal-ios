// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayPal",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CorePayments",
            targets: ["CorePayments"]
        ),
        .library(
           name: "PayPalNativePayments",
           targets: ["PayPalNativePayments"]
        ),
        .library(
            name: "PaymentButtons",
            targets: ["PaymentButtons"]
        ),
        .library(
            name: "PayPalWebPayments",
            targets: ["PayPalWebPayments"]
        ),
        .library(
            name: "CardPayments",
            targets: ["CardPayments"]
        ),
        .library(
            name: "FraudProtection",
            targets: ["FraudProtection", "PPRiskMagnes"]
        )
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
           name: "PayPalNativePayments",
           dependencies: ["CorePayments", "PayPalCheckout"],
           resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "PaymentButtons",
            dependencies: ["CorePayments"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "PayPalWebPayments",
            dependencies: ["CorePayments"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "FraudProtection",
            dependencies: ["CorePayments", "PPRiskMagnes"],
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
        ),
        .binaryTarget(
            name: "PayPalCheckout",
            url: "https://github.com/paypal/paypalcheckout-ios/releases/download/1.2.0/PayPalCheckout.xcframework.zip",
            checksum: "de177ea050cfd342aa1bbfe0d9ed7faf8262270a0291a5862b6ee3c7f85cc1ff"
        )
    ]
)
