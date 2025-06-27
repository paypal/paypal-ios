# What This Guide Will Cover

This guide will walk you through how to integrate the PayPal Checkout flows. With these steps, you will be able to integrate the following payment methods for 1-time checkout:

- PayPal
- PayPal Pay Later
- PayPal Credit

The checkout experience is browser-based and is launched on top of your app's current screen as an in-context experience; and, the SDK utilizes an `ASWebAuthenticationSession` for security purposes.

Additionally, you can use the provided customizable PayPal buttons within your app to fit your app’s user experience.

# Reference Code

If you prefer to dive into real-world code examples, refer to the GitHub repos below for an end-to-end demo app:

- [iOS demo app](https://github.com/paypal-examples/paypal-ios-sdk-demo-app)
- [Android demo app](https://github.com/paypal-examples/paypal-android-sdk-demo-app)
- [Demo Server](https://github.com/paypal-examples/paypal-mobile-sdk-demo-server)

# Know Before You Code

Before beginning the integration steps, you will need to [create a developer account](https://www.paypal.com/webapps/mpp/account-selection?intent=developer&country.x=US&locale.x=en_US) to get the credentials needed to use PayPal services. PayPal uses both the Client ID and Client Secret to interact with the APIs and SDKs; both of which can be found in the [developer dashboard](https://developer.paypal.com/dashboard/applications/sandbox).

> The Client ID and Client Secret are both tied to a PayPal “REST API Application” on the developer site. A default application is created for you when you create a developer account but you can create a new REST API Application by navigating to the [“Apps & Credentials” tab on the developer site](https://developer.paypal.com/dashboard/applications/sandbox).

> The Client ID authenticates your account with PayPal and identifies your app while the Client Secret authorizes your app. Keep the Client Secret safe and don’t share it.

In addition to integrating with the client-side SDK, you will also need a server-side API to complete the integration tasks that are not client safe. Each of the integration steps below will clearly define where you need to complete the step (app-side or server-side).

# PayPal Checkout Overview

In order to get the most out of this guide, it’s important to first understand the PayPal checkout process.

> PayPal checkout utilizes the [Orders API](https://developer.paypal.com/docs/api/orders/v2/) to create and manage a PayPal Order. An Order represents a payment between two or more parties; and with it, you can manage your customer’s transaction. It is the fundamental object used for managing checkout on PayPal’s platform. For more information on Orders and how to use the API, please refer to the [Orders API reference](https://developer.paypal.com/docs/api/orders/v2/).

PayPal checkout high-level steps:

1. From their mobile app, the merchant calls an endpoint on their server that creates a PayPal Order and returns the Order ID.
1. The PayPal SDK uses the Order’s ID to trigger the presentation of the “Review Your Purchase” page via an `ASWebAuthenticationSession` on iOS and `Chrome Custom Tab` on Android. This allows the customer to review and approve (or cancel) the purchase.
1. The customer approves the Order on the “Review Your Purchase” page.
1. The merchant authorizes or captures the Order on their server (see the below note for information on authorizing and capturing an order).

> After an Order is approved by the buyer, the Order must either be “authorized” or “captured” in order to process the money movement. If you want to charge the customer immediately, you must “capture” the order. In contrast, if you need to secure the funds on the customer’s account but don’t want to fully charge the account until a later time, you will want to “authorize” the order. Note that if you “authorize” an order, it will need to be eventually “captured” as well for the funds to be moved to your account.
>
> Consider “capturing” an Order when you can provide your product to your customer immediately (i.e. a digital purchase) and consider “authorizing” an Order when there is a delay for when you can provide the product to your customer (i.e. purchasing a physical product that needs to be processed and shipped). In the latter case, make sure you capture the Order at an appropriate time. For example, you can authorize the order when your customer purchases the item and capture the order when you ship the product.

# Integration Steps

Follow the steps below to integrate the `PayPalWebPayments` module to accept PayPal payments (including PayPal Pay Later and PayPal Credit).

## Step 1. [App] Add a Dependency to the PayPal iOS SDK

The first step is to add a dependency to the PayPal iOS SDK. This is supported either via Swift Package Manager or CocoaPods. Select the dependency manager of your choice below for the relevant steps:

**Option 1: Swift Package Manager (recommended)**

If you're using Swift Package Manager (SPM), follow the below steps to integrate the SDK:

1. Open your application with Xcode.
1. Add a package dependency using this [guide](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app).
    1. Use `https://github.com/paypal/paypal-ios/` as the repository URL.
    1. Select the packages you want to include in your target. Include at least:
        1. `PayPalWebPayments`
        1. `CorePayments`
        1. `PaymentButtons`

**Option 2: Cocoapods**

If you're using Cocoapods, include (at least) the following packages in your Podfile:

- `PayPalWebPayments`
- `CorePayments`
- `PaymentButtons`

Please refer to the Podfile below:

```
# Podfile
pod 'PayPal/PayPalWebPayments'
pod 'PayPal/CorePayments'
pod 'PayPal/PaymentButtons'
```

## Step 2. [App] Display the PayPal Button

After you add a dependency to the PayPal SDK, the next step is to display the PayPal button in your app. The button can be displayed anywhere that makes sense for your app (ex: in the cart, in the item detail page, or any other page). The PayPal SDK offers a PayPal button that can be customized to match the styling of your app - configure the button with the predefined color options, shape, and more!

```Swift
struct CartView: View {
    var body: some View {
        PayPalButton.Representable() {
            // TODO We'll fill this in later
        }
    }
}
```

<!-- Note to self: Switch step 2 and 3 with each other -->

## Step 3. [App] Create a `PayPalWebCheckoutClient`

The next step is to initialize a `PayPalWebCheckoutClient`. In order to do so, you will need to provide a `CoreConfig` object with the following information:

- `clientID`: The Client ID that is tied to the PayPal app created in the [developer dashboard](https://developer.paypal.com/dashboard/applications/sandbox).
- `environment`: The environment you want to process payments in. For now, you’ll want to set it to `sandbox` for testing purposes. However, when you’re ready to go to production, you will set it to `live`.

The `PayPalWebCheckoutClient` will be used to start the PayPal checkout flow and uses the `CoreConfig` to identify your PayPal application and route API calls to the right environment.

```Swift
struct CartView: View {
    private let paypalConfig: CoreConfig
    private let paypalClient: PayPalWebCheckoutClient

    init() {
        paypalConfig = CoreConfig(
            clientID: "<YOUR_CLIENT_ID_HERE>",
            environment: .sandbox // When you're ready for production, change this to `.live`
        )
        paypalClient = PayPalWebCheckoutClient(config: paypalConfig)
    }
}
```

## Step 4. [Server] Create an Order Creation Endpoint on Your Server

On your server, you will need to create an endpoint that calls PayPal’s [Orders API](https://developer.paypal.com/docs/api/orders/v2/) to create an Order. An Order represents a payment between two or more parties; and with it, you can manage your customer's transaction. It is the fundamental object used for managing checkout on PayPal’s platform. For more information on Orders and how to use the API, please refer to the [Orders API reference](https://developer.paypal.com/docs/api/orders/v2/).

When creating an Order, at minimum, you need to provide the following two things in the request body:

1. `intent`: The value of this field is either `CAPTURE` or `AUTHORIZE` and it simply indicates whether the payment should be immediately “captured” (i.e. charge the customer immediately) or “authorized” (i.e. secure the funds on the customer’s account but don’t fully charge the account). Note that if you “authorize” an order, it will need to be eventually “captured” as well to complete the Order and to move the funds from your customers' account to your account.
1. `purchase_unit`: In it’s simplest form, this field represents the currency and the amount of the transaction as an “amount” object. For example, if the order total for a transaction is $129.99 US Dollars, you would specify the currency code of “USD” and the amount of “129.99” in this field. Note that this field is an array of amount objects since you can specify more than one purchase unit. For more information on purchase units, please refer to the [Orders API reference page](https://developer.paypal.com/docs/api/orders/v2/#orders_create). For a list of supported currencies, please visit [this reference page](https://developer.paypal.com/api/rest/reference/currency-codes/).

```Javascript
// ---------- Create Order ----------
app.post('/checkout/order', createOrderAsync);
async function createOrderAsync(req, res) {
    const order = req.body;
    if (!order) {
        res.status(400).send({ message: 'Order is empty.' });
        return;
    }
    try {
        const result = await createPayPalOrderAsync(
            order.currencyCode, 
            order.paymentIntent, 
            getOrderTotal(order.items)
        );
        res.status(201).send({ id: result.id, status: result.status });
    } catch (error) {
        console.error('Failed to create order:', error);
        res.status(400).send({ error: 'Failed to create order.' });
    }
}
async function createPayPalOrderAsync(currencyCode, paymentIntent, amount) {
    const accessToken = await generateAccessTokenAsync();
    const url = `${baseUrl}/v2/checkout/orders`;
    const payload = {
        intent: paymentItent,
        purchase_units: [
            {
                amount: {
                    currency_code: currencyCode,
                    value: amount
                }
            }
        ]
    };
    const response = await fetch(url, {
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${accessToken}`
        },
        method: 'POST',
        body: JSON.stringify(payload)
    });
    return await response.json();
}
async function generateAccessTokenAsync() {
    const clientId = "<YOUR_CLIENT_ID_HERE>"; // Ideally, you get this from the environment like so: `process.env.PAYPAL_CLIENT_ID`
    const clientSecret = "<YOUR_CLIENT_SECRET_HERE>"; // Ideally, you get this from the environment like so: `process.env.PAYPAL_CLIENT_SECRET`
    const auth = Buffer.from(clientId + ':' + clientSecret).toString('base64');
    const response = await fetch(`${baseUrl}/v1/oauth2/token`, {
        method: 'POST',
        body: 'grant_type=client_credentials',
        headers: {
            Authorization: `Basic ${auth}`,
        },
    });
    const data = await response.json();
    return data.access_token;
}
function getOrderTotal(orderItems) {
    let amount = 0;
    orderItems.forEach((item) => {
        amount += item.price;
    });
    return amount;
}
```

## Step 5. [App] Call Your New Create Order Endpoint

Back on the app-side, call your new order creation endpoint from the previous step to kickstart the checkout process.

```Swift
private func createOrder() async throws -> CreateOrderResponse {
    try await Network.post(
        urlString: "<YOUR_CREATE_ORDER_ENDPOINT_URL>", // This is your endpoint that creates the order on the server-side.
        body: CreateOrderRequest( // This is a sample request body. You can make this object however your endpoint expects it to be.
            currencyCode: "USD", // Can be any supported currency code
            paymentIntent: "CAPTURE", // Can be "AUTHORIZE or CAPTURE"
            items: cartItems
        )
    )
}
```

## Step 6. [App] Start the PayPal Checkout Flow

Once you have created an Order, you will use the Order’s ID to start the PayPal Checkout flow. This is the part of the SDK that initializes an `ASWebAuthenticationSession` and displays the web view to allow your customers to approve the transaction.

```Swift
private func launchPayPalCheckout(orderId: String) async throws -> PayPalWebCheckoutResult {
    let request = PayPalWebCheckoutRequest(orderID: orderId, fundingSource: .paypal)
    return try await paypalClient.start(request: request)
}
```

## Step 7. [Server] Create an Endpoint on your Server to Capture/Authorize the Payment

Once your customer approves the transaction, you can capture/authorize the order. However, you will first need to create a new endpoint on your server to complete the transaction. Internally, your endpoint will either call the Orders API’s capture endpoint or the authorize endpoint - depending on the `intent` you chose when creating the Order. You can reference the code samples here for examples for both the `CAPTURE` and `AUTHORIZE` flows. However, for the purposes of our example, we will highlight the `CAPTURE` flow.

```Javascript
// ---------- Capture Order ----------
app.post('/checkout/order/:orderId/capture', captureOrderAsync);

async function captureOrderAsync(req, res) {
    const { orderId } = req.params;
    try {
        const result = await paypalCaptureOrderAsync(orderId);
        res.status(200).send({ id: result.id, status: result.status, paymentSource: result.payment_source});
    } catch (error) {
        res.status(400).send({ message: 'Failed to capture order.' });
    }
}

async function paypalCaptureOrderAsync(orderId) {
    const accessToken = await generateAccessTokenAsync();
    const url = `${baseUrl}/v2/checkout/orders/${orderId}/capture`;
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${accessToken}`
        },
    });
    return await response.json();
}
```

## Step 8. [App] Call your Capture/Authorize Endpoint

Now that you have an endpoint to either capture or authorize the order, you will need to call the relevant endpoint from the app. In our example, we will call the “capture” endpoint but you can call the “authorize” endpoint if that makes more sense for your use case. Just remember that if you choose to authorize the order, you will eventually need to also capture the order to complete the transaction.

Make the API call after the user approves the transaction via the `ASWebAuthenticationSession` that is shown when you started the PayPal checkout flow.

```Swift
private func captureOrder(orderId: String) async throws -> CaptureOrderResponse {
    try await Network.post(
        urlString: "<YOUR_CAPTURE_ORDER_ENDPOINT_URL>" // This is your endpoint that captures the order on the server-side.
    )
}
```

## Step 9. [App] Show your Customers that the Payment is Complete

Once you have either captured or authorized the payment, you have completed all the steps to provide PayPal Checkout for your customers. At this point, you can show an order confirmation view to your customers!

> Remember that if you chose to authorize the payment (instead of capture it), you will need to capture the payment at a later time to complete the order.

# More Integration Options

<!-- TODO -->

# Complete Code Reference

<!-- TODO -->