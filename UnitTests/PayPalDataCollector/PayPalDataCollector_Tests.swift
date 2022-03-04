import XCTest
@testable import PayPalDataCollector

class PayPalDataCollector_Tests: XCTestCase {

    private var deviceInspector = MockDeviceInspector()
    private var magnesSDK = MockMagnesSDK()

    func testCollectDeviceData_setsUpMagnes() {
        let sut = PayPalDataCollector(magnesSDK: magnesSDK, deviceInspector: deviceInspector)

        deviceInspector.stubPayPalDeviceIdentifierWithValue("paypal_device_identifier")
        _ = sut.collectDeviceData()

        let expectedParams = MagnesSetupParams(
            env: .LIVE,
            appGuid: "paypal_device_identifier",
            apnToken: "",
            isRemoteConfigDisabled: false,
            isBeaconDisabled: false,
            source: .BRAINTREE
        )
        XCTAssertTrue(magnesSDK.didSetUpWithParams(expectedParams))
    }
}
