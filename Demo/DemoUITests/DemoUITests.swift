//
//  DemoUITests.swift
//  DemoUITests
//
//  Created by Steven Shropshire on 2/22/22.
//

import XCTest

class DemoUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    func testExample() throws {
        XCTAssertTrue(true)
    }
}
