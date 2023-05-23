# PayPal Mobile Checkout SDK: Migration Guide

This guide outlines how to update your integration from using the soon-to-be-deprecated [PayPal Mobile Checkout SDK](https://developer.paypal.com/limited-release/paypal-mobile-checkout/) to the new PayPal Mobile [iOS SDK](https://github.com/paypal/iOS-SDK).

## Pre-Requisites
In order to use this migration guide, you must:

1. Have a server-side integration with the [PayPal Orders v2 API](https://developer.paypal.com/docs/api/orders/v2/). Please update to Orders v2 if you're on [Payments V1](https://developer.paypal.com/docs/api/payments/v1/) or [NVP/SOAP](https://developer.paypal.com/api/nvp-soap/).
1. Enable your server to [fetch an Access Token](https://developer.paypal.com/reference/get-an-access-token/).
1. Enable your server to create an [Order ID](https://developer.paypal.com/docs/api/orders/v2/).
1. Enable your server to [PATCH](https://developer.paypal.com/docs/api/orders/v2/#orders_patch) an order.
    * _Note:_ This is **only required** if you create your order ID with [`shipping_preference`](https://developer.paypal.com/docs/api/orders/v2/#definition-order_application_context) = `GET_FROM_FILE`. See step 6 in the guides below.

## Client-Side

*Assuming the pre-requisites are met, this migration should take ~1 developer day to complete.*

1. Add the new SDK to your app
  * Swift Package Manger
      * In Xcode, add the PayPal SDK as a [package dependency](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) to your Xcode project. Enter https://github.com/paypal/iOS-SDK.git as the package URL. 
      * Tick the `PayPalNativePayments`, `PaymentButtons`, and `CorePayments` boxes to add the libraries to your app.

  * CocoaPods
      * Include the `PayPalNativePayments`, and `PaymentButtons` sub-modules in your `Podfile`:
        ```ruby
        pod 'PayPal/PayPalNativePayments'
        pod 'PayPal/PaymentButtons'
        ```

    *Note*: Updating your existing `paypalcheckout-ios` dependency to the latest will resolve any dependency conflicts.
    
2. Update Configuration

    * Remove `CheckoutConfig` and related `set()` methods.
    * Instantiate a `CoreConfig` with your Access Token from the [pre-requisite](#pre-requisites) steps.
    * Construct a `PayPalNativeCheckoutClient`.
    * Set delegates (more details to follow).
    
    ```diff
    private func configurePayPalCheckout() {
    -     let config = CheckoutConfig(
    -         clientID: "<ACCESS_TOKEN>",
    -         environment: .sandbox
    -     )
    -     Checkout.set(config: config)     
    -     Checkout.setCreateOrderCallback { createOrderAction in
    -         createOrderAction.set(orderId: "<ORDER_ID>")
    -     }

    +     let coreConfig = CoreConfig(accessToken: "<ACCESS_TOKEN>"", environment: CorePayments.Environment.sandbox)
    +     paypalClient = PayPalNativeCheckoutClient(config: coreConfig)
    
    +     paypalClient?.delegate = self          // always required
    +     paypalClient?.shippingDelegate = self  // required for `GET_FROM_FILE` orders
    }
    ```

3. Update your Button

    * Update your UI to display a `PaymentButtons.PayPalButton()`, instead of a `PaymentButtonContainer()`.
    * The `PayPalButton` needs a corresponding `@objc` action method.

    ```diff
     private func addPayPalButton() {
    -    let container = PaymentButtonContainer()
    +    let paypalButton = PaymentButtons.PayPalButton()
    +    paypalButton.addTarget(self, action: #selector(payPalButtonTapped), for: .touchUpInside)

    -    view.addSubview(container)
    +    view.addSubview(paypalButton)
    }
    ```

4. Implement a button action method

    * Create a `PayPalNativeCheckoutRequest` with your Order ID from the [pre-requisite](#pre-requisites) steps.
    * Call `PayPalNativeCheckoutClient.start()` to present the PayPal Paysheet.

    ```diff
    + @objc private func payPalButtonTapped() {
    +     let request = PayPalNativeCheckoutRequest(orderID: "<ORDER_ID>")
    +     Task { await self.paypalClient?.start(request: request) }
    + }
    ```

5. Implement delegate & remove `Checkout` callbacks

    * Implement the required `PayPalNativeCheckoutDelegate`. This is how your app will receive notifications of the PayPal flow's success, cancel, error, and willStart events.
    * Remove the analogous `Checkout` singleton `setCallback()` methods.

    ```diff
    private func configurePayPalCheckout() {
    -    Checkout.setOnApproveCallback { approval in
    -        approval.actions.capture { response, error in
    -            // Handle result of order approval (authorize or capture)
    -    }
    -
    -    Checkout.setOnCancelCallback {
    -        // Handle cancel case
    -    }
    -
    -    Checkout.setOnErrorCallback { error in
    -        // Handle error case
    -    }
    -
    -    Checkout.setOnShippingChangeCallback { shippingChange, shippingChangeAction in
    -        // Handle user shipping address & method selection change
    -    }
    }

    + extension ViewController: PayPalNativeCheckoutDelegate {

    +    func paypal(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient, didFinishWithResult result: PayPalNativePayments.PayPalNativeCheckoutResult) {
    +        // Handle result of order approval (authorize or capture)
    +    }

    +    func paypal(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient, didFinishWithError error: CorePayments.CoreSDKError) {
    +        // Handle error case
    +    }

    +    func paypalDidCancel(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
    +        // Handle cancel case
    +    }

    +    func paypalWillStart(_ payPalClient: PayPalNativePayments.PayPalNativeCheckoutClient) {
    +        // Handle any UI clean-up before paysheet presents
    +    }
    + }
    ```
    
6. Implement shipping delegate

    :warning: Only implement `PayPalNativeShippingDelegate` if your order ID was created with [`shipping_preference`](https://developer.paypal.com/docs/api/orders/v2/#definition-experience_context_base) = `GET_FROM_FILE`. If you created your order ID with `shipping_preference` = `NO_SHIPPING` or `SET_PROVIDED_ADDRESS`, **skip this step** (step 6).


    * `PayPalNativeShippingDelegate` notifies your app when the user updates their shipping address **or** shipping method. 
        * In the previous SDK, both shipping change types were lumped into one `ShippingChangeCallback`.
    * You are required to PATCH the order details on your server if the shipping method (or amount) changes. Do this with the [PayPal Orders API - Update order](https://developer.paypal.com/docs/api/orders/v2/#orders_patch) functionality.

    ```diff
    + extension ViewController: PayPalNativeShippingDelegate {

    +    func paypal(
    +        _ payPalClient: PayPalNativeCheckoutClient,
    +        didShippingAddressChange shippingAddress: PayPalNativeShippingAddress,
    +        withAction shippingActions: PayPalNativePaysheetActions
    +    ) {
    +       // called when the user updates their chosen shipping address
    
    +       // REQUIRED: you must call actions.approve() or actions.reject() in this callback
    +       actions.approve()
    
    +       // OPTIONAL: you can optionally patch your order. Once complete, call actions.approve() if successful or actions.reject() if not.
    +    }
    
    +    func paypal(
    +        _ payPalClient: PayPalNativeCheckoutClient,
    +        didShippingMethodChange shippingMethod: PayPalNativeShippingMethod,
    +        withAction shippingActions: PayPalNativePaysheetActions
    +    ) {
    +        // Handle user shipping method selection change
    +
    +        // REQUIRED: patch your order server-side with the updated shipping amount
    +        // Once complete, call `actions.approve()` or `actions.reject()` 
    +        if patchOrder() == .success {
    +            actions.approve()
    +        } else {
    +            actions.reject()
    +        }
    +    }
    + }
    ```

7. Remove the old SDK dependency

* Swift Package Manager
    * Remove the `paypalcheckout-ios` package from your Xcode project's "Package Dependencies"
    * ![](https://iili.io/HO1okCB.png)

* CocoaPods
    * Remove `pod 'PayPalCheckout'` from your Podfile
    * Refresh your local `/Pods`
 
## Resources

We migrated a sample app for you to reference:

* [iOS PR](https://github.com/scannillo/paypal-xo-sample/pull/1): ➕101 lines ➖39 lines
