import XCTest

final class PetappUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchAndTabNavigationSmoke() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["tab.home"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["tab.calendar"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["tab.aiChat"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["tab.profile"].waitForExistence(timeout: 2))

        app.buttons["tab.calendar"].tap()
        app.buttons["tab.profile"].tap()
        app.buttons["tab.home"].tap()
        app.buttons["tab.aiChat"].tap()
        XCTAssertTrue(app.otherElements["screen.ai"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPawsyButtonOpensHub() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["pawsy.center.pill"].waitForExistence(timeout: 3))
        app.buttons["pawsy.center.pill"].forceTap()
        XCTAssertTrue(app.otherElements["pawsy.hub"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testPetEditorFlowOpenEditSave() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.buttons["dashboard.menu"].waitForExistence(timeout: 3))
        app.buttons["dashboard.menu"].forceTap()
        XCTAssertTrue(app.buttons["dashboard.quick.settings"].waitForExistence(timeout: 3))
        app.buttons["dashboard.quick.settings"].forceTap()

        let nameField = app.textFields["pet.editor.name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 3))
        nameField.tap()
        nameField.clearAndType(text: "Baxter")

        let saveButton = app.buttons["pet.editor.save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 2))
        saveButton.tap()

        XCTAssertTrue(app.buttons["dashboard.menu"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCriticalAccessibilityIdentifiersExist() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.staticTexts["title.dashboard"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["dashboard.menu"].exists)
        XCTAssertTrue(app.buttons["tab.home"].exists)
        XCTAssertTrue(app.buttons["tab.calendar"].exists)
        XCTAssertTrue(app.buttons["tab.aiChat"].exists)
        XCTAssertTrue(app.buttons["tab.profile"].exists)
        XCTAssertTrue(app.buttons["pawsy.center.pill"].exists)
    }
}

private extension XCUIElement {
    @MainActor
    func forceTap() {
        if isHittable {
            tap()
            return
        }

        let coordinate = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        coordinate.tap()
    }

    func clearAndType(text: String) {
        guard let valueString = value as? String else {
            typeText(text)
            return
        }
        tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: valueString.count)
        typeText(deleteString + text)
    }
}
