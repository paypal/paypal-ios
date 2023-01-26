Pod::Spec.new do |s|
  s.name             = "PayPal"
  s.version          = "0.0.4"
  s.summary          = "The PayPal iOS SDK: Helps you accept card, PayPal, and alternative payment methods in your iOS app."
  s.homepage         = "https://developer.paypal.com/home"
  s.license          = "MIT"
  s.author           = { "PayPal" => "sdks@paypal.com" }
  s.source           = { :git => "https://github.com/paypal/iOS-SDK.git", :tag => s.version.to_s }
  s.swift_version    = "5.7"

  s.platform         = :ios, "14.0"
  s.compiler_flags = "-Wall -Werror -Wextra"

  s.subspec "CardPayments" do |s|
    s.source_files  = "Sources/CardPayments/**/*.swift"
    s.dependency "PayPal/PaymentsCore"
  end

  s.subspec "PayPalNativeCheckout" do |s|
   s.source_files  = "Sources/PayPalNativeCheckout/**/*.swift"
   s.dependency "PayPal/PaymentsCore"
   s.dependency "PayPalCheckout", "0.109.0"
  end

  s.subspec "PaymentButtons" do |s|
    s.source_files  = "Sources/PaymentButtons/*.swift"
    s.dependency "PayPal/PaymentsCore"
    s.resource_bundle = {
    	'PayPalSDK' => ['Sources/PaymentButtons/*.xcassets']
    }
  end

  s.subspec "PayPalWebCheckout" do |s|
    s.source_files  = "Sources/PayPalWebCheckout/*.swift"
    s.dependency "PayPal/PaymentsCore"
  end

  s.subspec "PayPalDataCollector" do |s|
    s.source_files = "Sources/PayPalDataCollector/*.swift"
    s.vendored_frameworks = "Frameworks/XCFrameworks/PPRiskMagnes.xcframework"
  end

  s.subspec "PaymentsCore" do |s|
    s.source_files  = "Sources/PaymentsCore/**/*.swift"
  end
end
