import XCTest

extension XCUIApplication {

    func button(named buttonName: String) -> XCUIElement {
        return buttons[buttonName]
    }

    func textField(named textFieldName: String) -> XCUIElement {
        return textFields[textFieldName]
    }

    func staticText(containing text: String) -> XCUIElement {
        // Ref: https://stackoverflow.com/a/47253096
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        return staticTexts.containing(predicate).element
    }
}
