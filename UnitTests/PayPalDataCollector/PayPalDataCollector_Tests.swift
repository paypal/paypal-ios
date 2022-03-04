import XCTest
@testable import PayPalDataCollector

class PayPalDataCollector_Tests: XCTestCase {

    private var deviceInspector = MockDeviceInspector()
    private var magnesSDK = MockMagnesSDK()

    func testCollectDeviceData_setsMagnesEnvironmentToLIVE() {
        let sut = PayPalDataCollector(magnesSDK: magnesSDK, deviceInspector: deviceInspector)
        _ = sut.collectDeviceData()

        XCTAssertEqual(.LIVE, magnesSDK.capturedSetupParams?.env)
    }

    func testCollectDeviceData_setsMagnesAppGUIDToTheCurrentDeviceID() {
        deviceInspector.stubPayPalDeviceIdentifierWithValue("paypal_device_identifier")

        let sut = PayPalDataCollector(magnesSDK: magnesSDK, deviceInspector: deviceInspector)
        _ = sut.collectDeviceData()

        XCTAssertEqual("paypal_device_identifier", magnesSDK.capturedSetupParams?.appGuid)
    }

    func testCollectDeviceData_disablesMagnesRemoteConfiguration() {
        let sut = PayPalDataCollector(magnesSDK: magnesSDK, deviceInspector: deviceInspector)
        _ = sut.collectDeviceData()

        XCTAssertEqual(false, magnesSDK.capturedSetupParams?.isRemoteConfigDisabled)
    }

    func testCollectDeviceData_disablesMagnesBeacon() {
        let sut = PayPalDataCollector(magnesSDK: magnesSDK, deviceInspector: deviceInspector)
        _ = sut.collectDeviceData()

        XCTAssertEqual(false, magnesSDK.capturedSetupParams?.isBeaconDisabled)
    }
}
