// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PayPal",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "PaymentsCore",
            targets: ["PaymentsCore"]
        ),
        .library(
           name: "PayPalNativeCheckout",
           targets: ["PayPalNativeCheckout"]
        ),
        .library(
            name: "PayPalUI",
            targets: ["PayPalUI"]
        ),
        .library(
            name: "PayPalWebCheckout",
            targets: ["PayPalWebCheckout"]
        ),
        .library(
            name: "CardPayments",
            targets: ["CardPayments"]
        ),
        .library(
            name: "PayPalDataCollector",
            targets: ["PayPalDataCollector", "PPRiskMagnes"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PayPalCheckout", url: "https://github.com/paypal/paypalcheckout-ios", .exact("0.109.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "PaymentsCore",
            dependencies: []
        ),
        .target(
            name: "CardPayments",
            dependencies: ["PaymentsCore"]
        ),
        .target(
           name: "PayPalNativeCheckout",
           dependencies: ["PaymentsCore", "PayPalCheckout"]
        ),
        .target(
            name: "PayPalUI",
            dependencies: ["PaymentsCore"]
        ),
        .target(
            name: "PayPalWebCheckout",
            dependencies: ["PaymentsCore"]
        ),
        .target(
            name: "PayPalDataCollector",
            dependencies: ["PPRiskMagnes"]
        ),
        .binaryTarget(
            name: "PPRiskMagnes",
            path: "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
        )
    ]
)
