// swift-tools-version:5.7
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
            dependencies: []
        ),
        .target(
            name: "CardPayments",
            dependencies: ["CorePayments"]
        ),
        .target(
           name: "PayPalNativePayments",
           dependencies: ["CorePayments", "PayPalCheckout"]
        ),
        .target(
            name: "PaymentButtons",
            dependencies: ["CorePayments"]
        ),
        .target(
            name: "PayPalWebPayments",
            dependencies: ["CorePayments"]
        ),
        .target(
            name: "FraudProtection",
            dependencies: ["CorePayments", "PPRiskMagnes"]
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
        ),
        .binaryTarget(
            name: "PayPalCheckout",
            url: "https://github.com/paypal/paypalcheckout-ios/releases/download/1.1.0/PayPalCheckout.xcframework.zip",
            checksum: "e9e8d7ed4c48de1323bed5be81ddbc4fc82107506a6d23edc55689214f75f7ea"
        )
    ]
)
