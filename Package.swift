// swift-tools-version:5.8
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
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/paypal/paypalcheckout-ios", from: "1.1.0")
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
           dependencies: ["CorePayments", "PayPalCheckoutrm -f ~/Library/Caches/org.swift.swfitpm/repositories"]
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
        )
    ]
)
