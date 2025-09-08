import XCTest

final class MiniSiriCommandTest: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    // 1️⃣ Test: Text command - Play Music
    func testPlayMusicCommandShowsResponse() throws {
        let commandField = app.textFields["Type a command..."]
        XCTAssertTrue(commandField.exists)
        commandField.tap()
        commandField.typeText("play music")
        
        let submitButton = app.buttons["submit_button"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        let responseLabel = app.staticTexts["🎵 Now playing your playlist"]
        XCTAssertTrue(responseLabel.waitForExistence(timeout: 2))
    }
    
    // 2️⃣ Test: Text command - Invalid/fallback
    func testInvalidCommandShowsThinkingLLMFallback() throws {
        let commandField = app.textFields["Type a command..."]
        XCTAssertTrue(commandField.exists)
        commandField.tap()
        commandField.typeText("make coffee")
        
        let submitButton = app.buttons["submit_button"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        let fallbackText = app.staticTexts["Thinking... 🤖"]
        XCTAssertTrue(fallbackText.waitForExistence(timeout: 2))
    }
    
    // 3️⃣ Test: Quick command button - Call Mom
    func testQuickCommandButtonCallMom() throws {
        let callMomButton = app.buttons["command_call_mom"]
        XCTAssertTrue(callMomButton.exists)
        callMomButton.tap()
        
        let result = app.staticTexts["📞 Calling Mom..."]
        XCTAssertTrue(result.waitForExistence(timeout: 2))
    }
    
    // 4️⃣ Test: Quick command button - Weather
    func testQuickCommandButtonWeather() throws {
        let weatherButton = app.buttons["command_what_s_the_weather"]
        XCTAssertTrue(weatherButton.exists)
        weatherButton.tap()

        let result = app.staticTexts["☁️ 72°F, Partly Cloudy"]
        XCTAssertTrue(result.waitForExistence(timeout: 2))
    }
    //5. Submit empty text field shows validation error
    func testSubmitEmptyCommandShowsValidationError() throws {
        let commandField = app.textFields["Type a command..."]
        commandField.tap()
        commandField.typeText("")
        app.buttons["Submit"].tap()

        let errorText = app.staticTexts["Please enter a command."]
        XCTAssertTrue(errorText.waitForExistence(timeout: 2))
    }

    // 6️⃣ Test: Text command - Set Alarm
    func testSetAlarmCommandShowsResponse() throws {
        let commandField = app.textFields["Type a command..."]
        XCTAssertTrue(commandField.exists)
        commandField.tap()
        commandField.typeText("Set Alarm")
        
        let submitButton = app.buttons["submit_button"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        let responseLabel = app.staticTexts["⏰ Alarm set for 7:00 AM"]
        XCTAssertTrue(responseLabel.waitForExistence(timeout: 2))
    }

    // 7️⃣ Test: Text command - Open Calendar
    func testOpenCalendarCommandShowsResponse() throws {
        let commandField = app.textFields["Type a command..."]
        XCTAssertTrue(commandField.exists)
        commandField.tap()
        commandField.typeText("Open Calendar")
        
        let submitButton = app.buttons["submit_button"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        let responseLabel = app.staticTexts["📅 Opening your calendar"]
        XCTAssertTrue(responseLabel.waitForExistence(timeout: 2))
    }

    // 8️⃣ Test: Text command - Send Message
    func testSendMessageCommandShowsResponse() throws {
        let commandField = app.textFields["Type a command..."]
        XCTAssertTrue(commandField.exists)
        commandField.tap()
        commandField.typeText("Send Message")
        
        let submitButton = app.buttons["submit_button"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        let responseLabel = app.staticTexts["📨 Who would you like to message?"]
        XCTAssertTrue(responseLabel.waitForExistence(timeout: 2))
    }

    //9. whitespace command input
    func testWhitespaceCommandInputTrimmed() throws {
        let commandField = app.textFields["Type a command..."]
        commandField.tap()
        commandField.typeText("   play music   ")
        
        let submitButton = app.buttons["submit_button"]
        submitButton.tap()
        
        let response = app.staticTexts["🎵 Now playing your playlist"]
        XCTAssertTrue(response.waitForExistence(timeout: 2))
    }
    //10 buttons are visible and hittable
    func testQuickCommandButtonsAreVisible() throws {
        XCTAssertTrue(app.buttons["command_play_music"].isHittable)
        XCTAssertTrue(app.buttons["command_call_mom"].isHittable)
        XCTAssertTrue(app.buttons["command_what_s_the_weather"].isHittable)
    }
    
    //
    private func sanitizeIdentifier(_ command: String) -> String {
        return command
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: "_", options: .regularExpression)
            .replacingOccurrences(of: "_+", with: "_", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_"))
    }

    // 11 ✅ Loop through buttons dynamically
    func testQuickCommandButtonsLoopedAndVisible() throws {
    let expectedButtons = ["play music", "call mom", "what's the weather?"]


    for command in expectedButtons {
    let identifier = "command_" + sanitizeIdentifier(command)
    let button = app.buttons[identifier]


    XCTAssertTrue(button.exists, "Expected button \(command) not found")
    XCTAssertTrue(button.isHittable, "Button \(command) not tappable")
    }
    }
    // 12 ✅ Using XCTContext.runActivity for better diagnostics
    func testSubmitPlayMusicWithAnnotatedSteps() throws {
    XCTContext.runActivity(named: "Locate and tap command field") { _ in
    let field = app.textFields["Type a command..."]
    XCTAssertTrue(field.exists)
    field.tap()
    field.typeText("play music")
    }


    XCTContext.runActivity(named: "Tap submit and check response") { _ in
    let submit = app.buttons["submit_button"]
    XCTAssertTrue(submit.exists)
    submit.tap()


    let response = app.staticTexts["🎵 Now playing your playlist"]
    XCTAssertTrue(response.waitForExistence(timeout: 2))
    }
    }
    
   

}

