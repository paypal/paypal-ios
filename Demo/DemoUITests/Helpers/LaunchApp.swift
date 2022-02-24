import XCTest

func launchApp(withArgs launchArgs: [String] = []) -> XCUIApplication {
    let app = XCUIApplication()
    for arg in launchArgs {
        app.launchArguments.append(arg)
    }
    app.launch()
    return app
}
